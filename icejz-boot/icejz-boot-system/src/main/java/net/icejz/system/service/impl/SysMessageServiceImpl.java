package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.dao.SysMessageDao;
import net.icejz.system.dao.SysMessageUserDao;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysMessageEntity;
import net.icejz.system.entity.SysMessageUserEntity;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.enums.UserStatusEnum;
import net.icejz.system.query.SysMessageMyQuery;
import net.icejz.system.query.SysMessageQuery;
import net.icejz.system.service.SysMessageService;
import net.icejz.system.vo.SysMessageMyVO;
import net.icejz.system.vo.SysMessageVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 站内消息
 */
@Service
@AllArgsConstructor
public class SysMessageServiceImpl extends BaseServiceImpl<SysMessageDao, SysMessageEntity> implements SysMessageService {
    private final SysMessageUserDao sysMessageUserDao;
    private final SysUserDao sysUserDao;

    @Override
    public PageResult<SysMessageVO> page(SysMessageQuery query) {
        LambdaQueryWrapper<SysMessageEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StrUtil.isNotBlank(query.getTitle()), SysMessageEntity::getTitle, query.getTitle());
        wrapper.eq(query.getType() != null, SysMessageEntity::getType, query.getType());
        wrapper.eq(query.getStatus() != null, SysMessageEntity::getStatus, query.getStatus());
        wrapper.orderByDesc(SysMessageEntity::getCreateTime);

        IPage<SysMessageEntity> page = baseMapper.selectPage(getPage(query), wrapper);
        List<SysMessageVO> list = BeanUtil.copyToList(page.getRecords(), SysMessageVO.class);
        fillReceiverStats(list);
        return new PageResult<>(list, page.getTotal());
    }

    @Override
    public SysMessageVO getInfo(Long id) {
        SysMessageEntity entity = baseMapper.selectById(id);
        if (entity == null) {
            throw new ServerException("消息不存在");
        }
        SysMessageVO vo = BeanUtil.copyProperties(entity, SysMessageVO.class);
        List<SysMessageUserEntity> receivers = sysMessageUserDao.selectList(
                new LambdaQueryWrapper<SysMessageUserEntity>().eq(SysMessageUserEntity::getMessageId, id)
        );
        vo.setReceiverIdList(receivers.stream().map(SysMessageUserEntity::getReceiverId).toList());
        vo.setReceiverCount(receivers.size());
        vo.setReadCount((int) receivers.stream().filter(item -> Objects.equals(item.getReadStatus(), 1)).count());
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void send(SysMessageVO vo) {
        UserDetail user = SecurityUser.getUser();
        if (user == null) {
            throw new ServerException("未登录");
        }

        List<SysUserEntity> receivers = resolveReceivers(vo);
        if (receivers.isEmpty()) {
            throw new ServerException("没有可发送的接收人");
        }

        SysMessageEntity entity = BeanUtil.copyProperties(vo, SysMessageEntity.class);
        entity.setId(null);
        entity.setSenderId(user.getId());
        entity.setSenderName(StrUtil.blankToDefault(user.getRealName(), user.getUsername()));
        entity.setStatus(1);
        entity.setSendTime(LocalDateTime.now());
        entity.setTenantId(user.getTenantId());
        baseMapper.insert(entity);

        List<SysMessageUserEntity> rows = new ArrayList<>(receivers.size());
        for (SysUserEntity receiver : receivers) {
            SysMessageUserEntity row = new SysMessageUserEntity();
            row.setMessageId(entity.getId());
            row.setReceiverId(receiver.getId());
            row.setReceiverName(StrUtil.blankToDefault(receiver.getRealName(), receiver.getUsername()));
            row.setReadStatus(0);
            rows.add(row);
        }
        rows.forEach(sysMessageUserDao::insert);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        if (CollUtil.isEmpty(idList)) {
            return;
        }
        removeByIds(idList);
        sysMessageUserDao.delete(new LambdaQueryWrapper<SysMessageUserEntity>()
                .in(SysMessageUserEntity::getMessageId, idList));
    }

    @Override
    public PageResult<SysMessageMyVO> myPage(SysMessageMyQuery query) {
        Long userId = requireUserId();
        Page<SysMessageMyVO> page = new Page<>(query.getPage(), query.getLimit());
        IPage<SysMessageMyVO> result = sysMessageUserDao.selectMyPage(page, userId, query.getReadStatus(), query.getTitle());
        return new PageResult<>(result.getRecords(), result.getTotal());
    }

    @Override
    public SysMessageMyVO myInfo(Long id) {
        Long userId = requireUserId();
        SysMessageUserEntity receive = sysMessageUserDao.selectOne(new LambdaQueryWrapper<SysMessageUserEntity>()
                .eq(SysMessageUserEntity::getMessageId, id)
                .eq(SysMessageUserEntity::getReceiverId, userId)
                .last("LIMIT 1"));
        if (receive == null) {
            throw new ServerException("消息不存在或无权查看");
        }
        SysMessageEntity message = baseMapper.selectById(id);
        if (message == null || !Objects.equals(message.getStatus(), 1)) {
            throw new ServerException("消息不存在");
        }

        SysMessageMyVO vo = new SysMessageMyVO();
        vo.setId(message.getId());
        vo.setReceiveId(receive.getId());
        vo.setTitle(message.getTitle());
        vo.setContent(message.getContent());
        vo.setType(message.getType());
        vo.setSenderId(message.getSenderId());
        vo.setSenderName(message.getSenderName());
        vo.setSendTime(message.getSendTime());
        vo.setCreateTime(message.getCreateTime());
        vo.setReadStatus(receive.getReadStatus());
        vo.setReadTime(receive.getReadTime());

        if (Objects.equals(vo.getReadStatus(), 0)) {
            markRead(vo.getReceiveId());
            vo.setReadStatus(1);
            vo.setReadTime(LocalDateTime.now());
        }
        return vo;
    }

    @Override
    public Long unreadCount() {
        return sysMessageUserDao.countUnread(requireUserId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void read(Long id) {
        Long userId = requireUserId();
        SysMessageUserEntity receive = sysMessageUserDao.selectOne(new LambdaQueryWrapper<SysMessageUserEntity>()
                .eq(SysMessageUserEntity::getMessageId, id)
                .eq(SysMessageUserEntity::getReceiverId, userId)
                .last("LIMIT 1"));
        if (receive == null) {
            throw new ServerException("消息不存在或无权操作");
        }
        markRead(receive.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void readAll() {
        Long userId = requireUserId();
        List<SysMessageUserEntity> list = sysMessageUserDao.selectList(new LambdaQueryWrapper<SysMessageUserEntity>()
                .eq(SysMessageUserEntity::getReceiverId, userId)
                .eq(SysMessageUserEntity::getReadStatus, 0));
        LocalDateTime now = LocalDateTime.now();
        for (SysMessageUserEntity item : list) {
            item.setReadStatus(1);
            item.setReadTime(now);
            sysMessageUserDao.updateById(item);
        }
    }

    @Override
    public List<SysMessageMyVO> latest(int limit) {
        Long userId = requireUserId();
        int size = Math.max(1, Math.min(limit, 20));
        Page<SysMessageMyVO> page = new Page<>(1, size);
        return sysMessageUserDao.selectMyPage(page, userId, null, null).getRecords();
    }

    private List<SysUserEntity> resolveReceivers(SysMessageVO vo) {
        if (Objects.equals(vo.getReceiverType(), 0)) {
            return sysUserDao.selectList(new LambdaQueryWrapper<SysUserEntity>()
                    .eq(SysUserEntity::getStatus, UserStatusEnum.ENABLED.getValue())
                    .select(SysUserEntity::getId, SysUserEntity::getUsername, SysUserEntity::getRealName));
        }
        if (CollUtil.isEmpty(vo.getReceiverIdList())) {
            throw new ServerException("请选择接收人");
        }
        List<SysUserEntity> users = sysUserDao.selectBatchIds(vo.getReceiverIdList());
        return users.stream()
                .filter(item -> Objects.equals(item.getStatus(), UserStatusEnum.ENABLED.getValue()))
                .toList();
    }

    private void fillReceiverStats(List<SysMessageVO> list) {
        if (CollUtil.isEmpty(list)) {
            return;
        }
        List<Long> ids = list.stream().map(SysMessageVO::getId).toList();
        List<SysMessageUserEntity> receivers = sysMessageUserDao.selectList(
                new LambdaQueryWrapper<SysMessageUserEntity>().in(SysMessageUserEntity::getMessageId, ids)
        );
        Map<Long, List<SysMessageUserEntity>> grouped = receivers.stream()
                .collect(Collectors.groupingBy(SysMessageUserEntity::getMessageId));
        for (SysMessageVO item : list) {
            List<SysMessageUserEntity> rows = grouped.getOrDefault(item.getId(), List.of());
            item.setReceiverCount(rows.size());
            item.setReadCount((int) rows.stream().filter(row -> Objects.equals(row.getReadStatus(), 1)).count());
        }
    }

    private void markRead(Long receiveId) {
        SysMessageUserEntity entity = sysMessageUserDao.selectById(receiveId);
        if (entity == null || Objects.equals(entity.getReadStatus(), 1)) {
            return;
        }
        entity.setReadStatus(1);
        entity.setReadTime(LocalDateTime.now());
        sysMessageUserDao.updateById(entity);
    }

    private Long requireUserId() {
        Long userId = SecurityUser.getUserId();
        if (userId == null) {
            throw new ServerException("未登录");
        }
        return userId;
    }
}
