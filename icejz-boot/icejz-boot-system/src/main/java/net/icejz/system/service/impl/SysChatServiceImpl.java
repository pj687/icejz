package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.dao.SysChatConversationDao;
import net.icejz.system.dao.SysChatMemberDao;
import net.icejz.system.dao.SysChatMessageDao;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysChatConversationEntity;
import net.icejz.system.entity.SysChatMemberEntity;
import net.icejz.system.entity.SysChatMessageEntity;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.enums.SuperAdminEnum;
import net.icejz.system.query.SysChatConversationQuery;
import net.icejz.system.query.SysChatMessageQuery;
import net.icejz.system.service.SysChatAclService;
import net.icejz.system.service.SysChatService;
import net.icejz.system.vo.*;
import net.icejz.websocket.message.JsonDataMessage;
import net.icejz.websocket.sender.WebSocketMessageSender;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 企业内部聊天
 */
@Service
@RequiredArgsConstructor
public class SysChatServiceImpl extends BaseServiceImpl<SysChatConversationDao, SysChatConversationEntity>
        implements SysChatService {

    private final SysChatMemberDao memberDao;
    private final SysChatMessageDao messageDao;
    private final SysUserDao sysUserDao;
    private final SysChatAclService sysChatAclService;
    private final ObjectProvider<WebSocketMessageSender> webSocketSender;

    private static final int TYPE_DIRECT = 1;
    private static final int TYPE_GROUP = 2;
    private static final int MSG_TEXT = 0;
    private static final int MSG_IMAGE = 1;
    private static final int MSG_FILE = 2;
    private static final int MSG_SYSTEM = 9;
    private static final int ROLE_MEMBER = 0;
    private static final int ROLE_ADMIN = 1;
    private static final int ROLE_OWNER = 2;

    @Override
    public PageResult<SysChatConversationVO> conversationPage(SysChatConversationQuery query) {
        UserDetail user = requireUser();
        List<SysChatMemberEntity> myMemberships = memberDao.selectList(
                new LambdaQueryWrapper<SysChatMemberEntity>().eq(SysChatMemberEntity::getUserId, user.getId())
        );
        if (myMemberships.isEmpty()) {
            return new PageResult<>(List.of(), 0);
        }
        Map<Long, SysChatMemberEntity> membershipMap = myMemberships.stream()
                .collect(Collectors.toMap(SysChatMemberEntity::getConversationId, m -> m, (a, b) -> a));
        Set<Long> convIds = membershipMap.keySet();

        LambdaQueryWrapper<SysChatConversationEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(SysChatConversationEntity::getId, convIds);
        wrapper.eq(SysChatConversationEntity::getStatus, 1);
        wrapper.orderByDesc(SysChatConversationEntity::getLastMsgTime)
                .orderByDesc(SysChatConversationEntity::getId);

        IPage<SysChatConversationEntity> page = baseMapper.selectPage(getPage(query), wrapper);
        List<SysChatConversationVO> list = page.getRecords().stream()
                .map(c -> toConversationVO(c, membershipMap.get(c.getId()), user.getId()))
                .collect(Collectors.toList());

        if (StrUtil.isNotBlank(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            list = list.stream()
                    .filter(v -> StrUtil.containsIgnoreCase(StrUtil.blankToDefault(v.getDisplayName(), ""), kw)
                            || StrUtil.containsIgnoreCase(StrUtil.blankToDefault(v.getLastMsgContent(), ""), kw))
                    .collect(Collectors.toList());
        }
        return new PageResult<>(list, page.getTotal());
    }

    @Override
    public SysChatConversationVO conversationInfo(Long id) {
        UserDetail user = requireUser();
        SysChatConversationEntity conv = requireConversation(id);
        SysChatMemberEntity me = requireMember(id, user.getId());
        SysChatConversationVO vo = toConversationVO(conv, me, user.getId());
        vo.setMembers(members(id));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysChatConversationVO createDirect(SysChatDirectVO vo) {
        UserDetail user = requireUser();
        requireAuthority(user, "sys:chat:direct");
        if (Objects.equals(user.getId(), vo.getUserId())) {
            throw new ServerException("不能与自己发起单聊");
        }
        SysUserEntity peer = sysUserDao.selectById(vo.getUserId());
        if (peer == null || Objects.equals(peer.getDeleted(), 1)) {
            throw new ServerException("对方用户不存在");
        }
        sysChatAclService.assertCanChat(user.getId(), vo.getUserId());

        String directKey = buildDirectKey(user.getId(), vo.getUserId());
        SysChatConversationEntity exist = baseMapper.selectOne(
                new LambdaQueryWrapper<SysChatConversationEntity>()
                        .eq(SysChatConversationEntity::getDirectKey, directKey)
                        .eq(SysChatConversationEntity::getStatus, 1)
                        .last("limit 1")
        );
        if (exist != null) {
            return conversationInfo(exist.getId());
        }

        SysChatConversationEntity conv = new SysChatConversationEntity();
        conv.setType(TYPE_DIRECT);
        conv.setOwnerId(user.getId());
        conv.setDirectKey(directKey);
        conv.setStatus(1);
        conv.setTenantId(user.getTenantId());
        conv.setLastMsgContent("会话已创建");
        conv.setLastMsgType(MSG_SYSTEM);
        conv.setLastMsgTime(LocalDateTime.now());
        baseMapper.insert(conv);

        addMember(conv.getId(), user.getId(), ROLE_OWNER);
        addMember(conv.getId(), peer.getId(), ROLE_MEMBER);

        SysChatMessageEntity sysMsg = insertSystemMessage(conv.getId(), user,
                StrUtil.format("{} 发起了会话", displayName(user)));
        touchConversation(conv, sysMsg);
        pushEvent(List.of(user.getId(), peer.getId()), "chat.new", Map.of(
                "conversationId", conv.getId(),
                "message", toMessageVO(sysMsg, user.getId())
        ));
        return conversationInfo(conv.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysChatConversationVO createGroup(SysChatGroupVO vo) {
        UserDetail user = requireUser();
        requireAuthority(user, "sys:chat:group");

        LinkedHashSet<Long> memberIds = new LinkedHashSet<>();
        memberIds.add(user.getId());
        memberIds.addAll(vo.getMemberIds());
        memberIds.remove(null);
        if (memberIds.size() < 2) {
            throw new ServerException("群聊至少需要两名成员");
        }

        List<SysUserEntity> users = sysUserDao.selectBatchIds(memberIds);
        if (users.size() != memberIds.size()) {
            throw new ServerException("存在无效成员");
        }
        sysChatAclService.assertCanChatAll(user.getId(), memberIds);

        SysChatConversationEntity conv = new SysChatConversationEntity();
        conv.setType(TYPE_GROUP);
        conv.setTitle(vo.getTitle().trim());
        conv.setAvatar(vo.getAvatar());
        conv.setOwnerId(user.getId());
        conv.setStatus(1);
        conv.setTenantId(user.getTenantId());
        conv.setLastMsgContent("群聊已创建");
        conv.setLastMsgType(MSG_SYSTEM);
        conv.setLastMsgTime(LocalDateTime.now());
        baseMapper.insert(conv);

        for (Long uid : memberIds) {
            addMember(conv.getId(), uid, Objects.equals(uid, user.getId()) ? ROLE_OWNER : ROLE_MEMBER);
        }

        SysChatMessageEntity sysMsg = insertSystemMessage(conv.getId(), user,
                StrUtil.format("{} 创建了群聊「{}」", displayName(user), conv.getTitle()));
        touchConversation(conv, sysMsg);
        pushEvent(new ArrayList<>(memberIds), "chat.new", Map.of(
                "conversationId", conv.getId(),
                "message", toMessageVO(sysMsg, user.getId())
        ));
        return conversationInfo(conv.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addMembers(SysChatMemberUpdateVO vo) {
        UserDetail user = requireUser();
        SysChatConversationEntity conv = requireConversation(vo.getConversationId());
        if (!Objects.equals(conv.getType(), TYPE_GROUP)) {
            throw new ServerException("仅群聊可添加成员");
        }
        assertCanManage(user, conv);
        sysChatAclService.assertCanChatAll(user.getId(), vo.getUserIds());

        for (Long uid : vo.getUserIds()) {
            if (uid == null) {
                continue;
            }
            SysChatMemberEntity exist = memberDao.selectOne(new LambdaQueryWrapper<SysChatMemberEntity>()
                    .eq(SysChatMemberEntity::getConversationId, conv.getId())
                    .eq(SysChatMemberEntity::getUserId, uid)
                    .last("limit 1"));
            if (exist != null) {
                continue;
            }
            SysUserEntity u = sysUserDao.selectById(uid);
            if (u == null) {
                continue;
            }
            int role = vo.getRole() != null && vo.getRole() == ROLE_ADMIN ? ROLE_ADMIN : ROLE_MEMBER;
            addMember(conv.getId(), uid, role);
            SysChatMessageEntity sysMsg = insertSystemMessage(conv.getId(), user,
                    StrUtil.format("{} 邀请 {} 加入群聊", displayName(user), StrUtil.blankToDefault(u.getRealName(), u.getUsername())));
            touchConversation(conv, sysMsg);
            List<Long> receivers = memberUserIds(conv.getId());
            pushEvent(receivers, "chat.new", Map.of("conversationId", conv.getId(), "message", toMessageVO(sysMsg, user.getId())));
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void removeMembers(SysChatMemberUpdateVO vo) {
        UserDetail user = requireUser();
        SysChatConversationEntity conv = requireConversation(vo.getConversationId());
        if (!Objects.equals(conv.getType(), TYPE_GROUP)) {
            throw new ServerException("仅群聊可移除成员");
        }
        assertCanManage(user, conv);

        for (Long uid : vo.getUserIds()) {
            if (uid == null || Objects.equals(uid, conv.getOwnerId())) {
                continue;
            }
            SysChatMemberEntity exist = memberDao.selectOne(new LambdaQueryWrapper<SysChatMemberEntity>()
                    .eq(SysChatMemberEntity::getConversationId, conv.getId())
                    .eq(SysChatMemberEntity::getUserId, uid)
                    .last("limit 1"));
            if (exist == null) {
                continue;
            }
            memberDao.deleteById(exist.getId());
            SysUserEntity u = sysUserDao.selectById(uid);
            String name = u == null ? String.valueOf(uid) : StrUtil.blankToDefault(u.getRealName(), u.getUsername());
            SysChatMessageEntity sysMsg = insertSystemMessage(conv.getId(), user,
                    StrUtil.format("{} 将 {} 移出群聊", displayName(user), name));
            touchConversation(conv, sysMsg);
            List<Long> receivers = memberUserIds(conv.getId());
            receivers.add(uid);
            pushEvent(receivers, "chat.new", Map.of("conversationId", conv.getId(), "message", toMessageVO(sysMsg, user.getId())));
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void dissolve(Long conversationId) {
        UserDetail user = requireUser();
        SysChatConversationEntity conv = requireConversation(conversationId);
        assertCanManage(user, conv);
        List<Long> receivers = memberUserIds(conversationId);
        conv.setStatus(0);
        baseMapper.updateById(conv);
        SysChatMessageEntity sysMsg = insertSystemMessage(conversationId, user,
                StrUtil.format("{} 解散了会话", displayName(user)));
        touchConversation(conv, sysMsg);
        pushEvent(receivers, "chat.dissolve", Map.of("conversationId", conversationId));
    }

    @Override
    public PageResult<SysChatMessageVO> messagePage(SysChatMessageQuery query) {
        UserDetail user = requireUser();
        requireMember(query.getConversationId(), user.getId());

        LambdaQueryWrapper<SysChatMessageEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysChatMessageEntity::getConversationId, query.getConversationId());
        wrapper.lt(query.getBeforeId() != null, SysChatMessageEntity::getId, query.getBeforeId());
        wrapper.orderByDesc(SysChatMessageEntity::getId);

        IPage<SysChatMessageEntity> page = messageDao.selectPage(new Page<>(query.getPage(), query.getLimit()), wrapper);
        List<SysChatMessageVO> list = page.getRecords().stream()
                .map(m -> toMessageVO(m, user.getId()))
                .collect(Collectors.toList());
        Collections.reverse(list);
        return new PageResult<>(list, page.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysChatMessageVO sendMessage(SysChatMessageVO vo) {
        UserDetail user = requireUser();
        SysChatConversationEntity conv = requireConversation(vo.getConversationId());
        if (!Objects.equals(conv.getStatus(), 1)) {
            throw new ServerException("会话已解散");
        }
        requireMember(conv.getId(), user.getId());
        assertCanSendByAcl(user, conv);

        int msgType = vo.getMsgType() == null ? MSG_TEXT : vo.getMsgType();
        if (msgType == MSG_FILE || msgType == MSG_IMAGE) {
            if (msgType == MSG_FILE) {
                requireAuthority(user, "sys:chat:file");
            }
            if (StrUtil.isBlank(vo.getFileUrl())) {
                throw new ServerException("请先上传文件");
            }
        } else if (msgType == MSG_TEXT) {
            if (StrUtil.isBlank(vo.getContent())) {
                throw new ServerException("消息内容不能为空");
            }
        } else {
            throw new ServerException("不支持的消息类型");
        }

        SysChatMessageEntity entity = new SysChatMessageEntity();
        entity.setConversationId(conv.getId());
        entity.setSenderId(user.getId());
        entity.setSenderName(displayName(user));
        entity.setMsgType(msgType);
        entity.setContent(StrUtil.blankToDefault(vo.getContent(), ""));
        entity.setFileUrl(vo.getFileUrl());
        entity.setFileName(vo.getFileName());
        entity.setFileSize(vo.getFileSize());
        entity.setStatus(1);
        messageDao.insert(entity);

        touchConversation(conv, entity);
        // 发送人视为已读到该消息
        SysChatMemberEntity me = requireMember(conv.getId(), user.getId());
        me.setLastReadMsgId(entity.getId());
        memberDao.updateById(me);

        SysChatMessageVO result = toMessageVO(entity, user.getId());
        pushEvent(memberUserIds(conv.getId()), "chat.new", Map.of(
                "conversationId", conv.getId(),
                "message", result
        ));
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void read(Long conversationId) {
        UserDetail user = requireUser();
        requireConversation(conversationId);
        SysChatMemberEntity me = requireMember(conversationId, user.getId());
        SysChatMessageEntity last = messageDao.selectOne(new LambdaQueryWrapper<SysChatMessageEntity>()
                .eq(SysChatMessageEntity::getConversationId, conversationId)
                .orderByDesc(SysChatMessageEntity::getId)
                .last("limit 1"));
        Long lastId = last == null ? 0L : last.getId();
        me.setLastReadMsgId(lastId);
        memberDao.updateById(me);
        pushEvent(memberUserIds(conversationId), "chat.read", Map.of(
                "conversationId", conversationId,
                "userId", user.getId(),
                "lastReadMsgId", lastId
        ));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recall(Long messageId) {
        UserDetail user = requireUser();
        SysChatMessageEntity msg = messageDao.selectById(messageId);
        if (msg == null) {
            throw new ServerException("消息不存在");
        }
        SysChatConversationEntity conv = requireConversation(msg.getConversationId());
        requireMember(conv.getId(), user.getId());

        boolean canManage = hasAuthority(user, "sys:chat:manage") || isOwnerOrAdmin(conv, user.getId());
        boolean isMine = Objects.equals(msg.getSenderId(), user.getId());
        if (!isMine && !canManage) {
            throw new ServerException("无权撤回该消息");
        }
        if (Objects.equals(msg.getStatus(), 0)) {
            return;
        }
        msg.setStatus(0);
        msg.setContent("消息已撤回");
        messageDao.updateById(msg);

        if (Objects.equals(conv.getLastMsgId(), msg.getId())) {
            conv.setLastMsgContent("消息已撤回");
            conv.setLastMsgType(MSG_SYSTEM);
            baseMapper.updateById(conv);
        }
        pushEvent(memberUserIds(conv.getId()), "chat.recall", Map.of(
                "conversationId", conv.getId(),
                "messageId", msg.getId(),
                "message", toMessageVO(msg, user.getId())
        ));
    }

    @Override
    public Long unreadTotal() {
        UserDetail user = requireUser();
        List<SysChatMemberEntity> memberships = memberDao.selectList(
                new LambdaQueryWrapper<SysChatMemberEntity>().eq(SysChatMemberEntity::getUserId, user.getId())
        );
        long total = 0;
        for (SysChatMemberEntity m : memberships) {
            total += countUnread(m);
        }
        return total;
    }

    @Override
    public List<SysChatMemberVO> members(Long conversationId) {
        UserDetail user = requireUser();
        requireMember(conversationId, user.getId());
        List<SysChatMemberEntity> list = memberDao.selectList(new LambdaQueryWrapper<SysChatMemberEntity>()
                .eq(SysChatMemberEntity::getConversationId, conversationId)
                .orderByDesc(SysChatMemberEntity::getRole)
                .orderByAsc(SysChatMemberEntity::getId));
        if (list.isEmpty()) {
            return List.of();
        }
        Map<Long, SysUserEntity> userMap = sysUserDao.selectBatchIds(
                list.stream().map(SysChatMemberEntity::getUserId).toList()
        ).stream().collect(Collectors.toMap(SysUserEntity::getId, u -> u, (a, b) -> a));

        return list.stream().map(m -> {
            SysChatMemberVO vo = BeanUtil.copyProperties(m, SysChatMemberVO.class);
            SysUserEntity u = userMap.get(m.getUserId());
            if (u != null) {
                vo.setRealName(u.getRealName());
                vo.setUsername(u.getUsername());
                vo.setAvatar(u.getAvatar());
            }
            return vo;
        }).collect(Collectors.toList());
    }

    private SysChatConversationVO toConversationVO(SysChatConversationEntity conv, SysChatMemberEntity me, Long myId) {
        SysChatConversationVO vo = BeanUtil.copyProperties(conv, SysChatConversationVO.class);
        vo.setUnreadCount(me == null ? 0L : countUnread(me));
        vo.setMemberCount(Math.toIntExact(memberDao.selectCount(new LambdaQueryWrapper<SysChatMemberEntity>()
                .eq(SysChatMemberEntity::getConversationId, conv.getId()))));

        if (Objects.equals(conv.getType(), TYPE_DIRECT)) {
            List<SysChatMemberEntity> members = memberDao.selectList(new LambdaQueryWrapper<SysChatMemberEntity>()
                    .eq(SysChatMemberEntity::getConversationId, conv.getId()));
            Long peerId = members.stream().map(SysChatMemberEntity::getUserId)
                    .filter(uid -> !Objects.equals(uid, myId)).findFirst().orElse(null);
            vo.setPeerUserId(peerId);
            if (peerId != null) {
                SysUserEntity peer = sysUserDao.selectById(peerId);
                if (peer != null) {
                    vo.setDisplayName(StrUtil.blankToDefault(peer.getRealName(), peer.getUsername()));
                    vo.setDisplayAvatar(peer.getAvatar());
                }
            }
            if (StrUtil.isBlank(vo.getDisplayName())) {
                vo.setDisplayName("单聊");
            }
        } else {
            vo.setDisplayName(StrUtil.blankToDefault(conv.getTitle(), "群聊"));
            vo.setDisplayAvatar(conv.getAvatar());
        }
        return vo;
    }

    private SysChatMessageVO toMessageVO(SysChatMessageEntity entity, Long myId) {
        SysChatMessageVO vo = BeanUtil.copyProperties(entity, SysChatMessageVO.class);
        vo.setMine(Objects.equals(entity.getSenderId(), myId));
        SysUserEntity sender = sysUserDao.selectById(entity.getSenderId());
        if (sender != null) {
            vo.setSenderAvatar(sender.getAvatar());
            if (StrUtil.isBlank(vo.getSenderName())) {
                vo.setSenderName(StrUtil.blankToDefault(sender.getRealName(), sender.getUsername()));
            }
        }
        if (Objects.equals(entity.getStatus(), 0)) {
            vo.setContent("消息已撤回");
            vo.setFileUrl(null);
            vo.setFileName(null);
            vo.setFileSize(null);
        }
        return vo;
    }

    private long countUnread(SysChatMemberEntity me) {
        Long lastRead = me.getLastReadMsgId() == null ? 0L : me.getLastReadMsgId();
        return messageDao.selectCount(new LambdaQueryWrapper<SysChatMessageEntity>()
                .eq(SysChatMessageEntity::getConversationId, me.getConversationId())
                .gt(SysChatMessageEntity::getId, lastRead)
                .ne(SysChatMessageEntity::getSenderId, me.getUserId())
                .eq(SysChatMessageEntity::getStatus, 1));
    }

    private void addMember(Long conversationId, Long userId, int role) {
        SysChatMemberEntity member = new SysChatMemberEntity();
        member.setConversationId(conversationId);
        member.setUserId(userId);
        member.setRole(role);
        member.setMute(0);
        member.setLastReadMsgId(0L);
        member.setJoinTime(LocalDateTime.now());
        memberDao.insert(member);
    }

    private SysChatMessageEntity insertSystemMessage(Long conversationId, UserDetail user, String content) {
        SysChatMessageEntity entity = new SysChatMessageEntity();
        entity.setConversationId(conversationId);
        entity.setSenderId(user.getId());
        entity.setSenderName(displayName(user));
        entity.setMsgType(MSG_SYSTEM);
        entity.setContent(content);
        entity.setStatus(1);
        messageDao.insert(entity);
        return entity;
    }

    private void touchConversation(SysChatConversationEntity conv, SysChatMessageEntity msg) {
        conv.setLastMsgId(msg.getId());
        conv.setLastMsgType(msg.getMsgType());
        conv.setLastMsgTime(msg.getCreateTime() != null ? msg.getCreateTime() : LocalDateTime.now());
        String summary = msg.getContent();
        if (Objects.equals(msg.getMsgType(), MSG_IMAGE)) {
            summary = "[图片]";
        } else if (Objects.equals(msg.getMsgType(), MSG_FILE)) {
            summary = "[文件]" + StrUtil.blankToDefault(msg.getFileName(), "");
        } else if (Objects.equals(msg.getStatus(), 0)) {
            summary = "消息已撤回";
        }
        if (StrUtil.length(summary) > 200) {
            summary = StrUtil.sub(summary, 0, 200);
        }
        conv.setLastMsgContent(summary);
        baseMapper.updateById(conv);
    }

    private List<Long> memberUserIds(Long conversationId) {
        return memberDao.selectList(new LambdaQueryWrapper<SysChatMemberEntity>()
                        .eq(SysChatMemberEntity::getConversationId, conversationId))
                .stream().map(SysChatMemberEntity::getUserId).collect(Collectors.toList());
    }

    private void pushEvent(List<Long> userIds, String type, Object data) {
        if (CollUtil.isEmpty(userIds)) {
            return;
        }
        WebSocketMessageSender sender = webSocketSender.getIfAvailable();
        if (sender == null) {
            return;
        }
        JsonDataMessage<Object> message = new JsonDataMessage<>();
        message.setType(type);
        message.setData(data);
        sender.send(userIds.stream().distinct().collect(Collectors.toList()), message);
    }

    private String buildDirectKey(Long a, Long b) {
        long min = Math.min(a, b);
        long max = Math.max(a, b);
        return min + "_" + max;
    }

    private UserDetail requireUser() {
        UserDetail user = SecurityUser.getUser();
        if (user == null) {
            throw new ServerException("未登录");
        }
        return user;
    }

    private SysChatConversationEntity requireConversation(Long id) {
        SysChatConversationEntity conv = baseMapper.selectById(id);
        if (conv == null) {
            throw new ServerException("会话不存在");
        }
        return conv;
    }

    private SysChatMemberEntity requireMember(Long conversationId, Long userId) {
        SysChatMemberEntity me = memberDao.selectOne(new LambdaQueryWrapper<SysChatMemberEntity>()
                .eq(SysChatMemberEntity::getConversationId, conversationId)
                .eq(SysChatMemberEntity::getUserId, userId)
                .last("limit 1"));
        if (me == null) {
            throw new ServerException("你不在该会话中");
        }
        return me;
    }

    private void assertCanManage(UserDetail user, SysChatConversationEntity conv) {
        if (hasAuthority(user, "sys:chat:manage") || isOwnerOrAdmin(conv, user.getId())) {
            return;
        }
        throw new ServerException("无权管理该会话");
    }

    private void assertCanSendByAcl(UserDetail user, SysChatConversationEntity conv) {
        if (hasAuthority(user, "sys:chat:manage")) {
            return;
        }
        List<Long> peers = memberUserIds(conv.getId()).stream()
                .filter(id -> !Objects.equals(id, user.getId()))
                .collect(Collectors.toList());
        sysChatAclService.assertCanChatAll(user.getId(), peers);
    }

    private boolean isOwnerOrAdmin(SysChatConversationEntity conv, Long userId) {
        if (Objects.equals(conv.getOwnerId(), userId)) {
            return true;
        }
        SysChatMemberEntity me = memberDao.selectOne(new LambdaQueryWrapper<SysChatMemberEntity>()
                .eq(SysChatMemberEntity::getConversationId, conv.getId())
                .eq(SysChatMemberEntity::getUserId, userId)
                .last("limit 1"));
        return me != null && (Objects.equals(me.getRole(), ROLE_ADMIN) || Objects.equals(me.getRole(), ROLE_OWNER));
    }

    private void requireAuthority(UserDetail user, String authority) {
        if (!hasAuthority(user, authority)) {
            throw new ServerException("无权限：" + authority);
        }
    }

    private boolean hasAuthority(UserDetail user, String authority) {
        if (user.getSuperAdmin() != null && Objects.equals(user.getSuperAdmin(), SuperAdminEnum.YES.getValue())) {
            return true;
        }
        Set<String> set = user.getAuthoritySet();
        return set != null && set.contains(authority);
    }

    private String displayName(UserDetail user) {
        return StrUtil.blankToDefault(user.getRealName(), user.getUsername());
    }
}
