package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.system.dao.SysAiChatMessageDao;
import net.icejz.system.dao.SysAiChatSessionDao;
import net.icejz.system.entity.SysAiChatMessageEntity;
import net.icejz.system.entity.SysAiChatSessionEntity;
import net.icejz.system.service.SysAiChatSessionService;
import net.icejz.system.vo.SysAiChatMessageVO;
import net.icejz.system.vo.SysAiChatSessionVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * AI 对话会话
 */
@Service
@AllArgsConstructor
public class SysAiChatSessionServiceImpl extends BaseServiceImpl<SysAiChatSessionDao, SysAiChatSessionEntity>
        implements SysAiChatSessionService {

    private final SysAiChatMessageDao messageDao;

    @Override
    public List<SysAiChatSessionVO> listMine() {
        Long userId = SecurityUser.getUserId();
        List<SysAiChatSessionEntity> list = baseMapper.selectList(Wrappers.lambdaQuery(SysAiChatSessionEntity.class)
                .eq(SysAiChatSessionEntity::getUserId, userId)
                .orderByDesc(SysAiChatSessionEntity::getLastMsgTime)
                .orderByDesc(SysAiChatSessionEntity::getId));
        return BeanUtil.copyToList(list, SysAiChatSessionVO.class);
    }

    @Override
    public List<SysAiChatMessageVO> listMessages(Long sessionId) {
        SysAiChatSessionEntity session = requireMine(sessionId);
        List<SysAiChatMessageEntity> list = messageDao.selectList(Wrappers.lambdaQuery(SysAiChatMessageEntity.class)
                .eq(SysAiChatMessageEntity::getSessionId, session.getId())
                .orderByAsc(SysAiChatMessageEntity::getId));
        return BeanUtil.copyToList(list, SysAiChatMessageVO.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysAiChatSessionVO createMine(String title) {
        Long userId = SecurityUser.getUserId();
        SysAiChatSessionEntity entity = new SysAiChatSessionEntity();
        entity.setUserId(userId);
        entity.setTitle(StrUtil.blankToDefault(StrUtil.maxLength(StrUtil.trim(title), 40), "新对话"));
        entity.setLastMsgTime(LocalDateTime.now());
        baseMapper.insert(entity);
        return BeanUtil.copyProperties(entity, SysAiChatSessionVO.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMine(List<Long> idList) {
        if (idList == null || idList.isEmpty()) {
            return;
        }
        Long userId = SecurityUser.getUserId();
        LambdaQueryWrapper<SysAiChatSessionEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(SysAiChatSessionEntity::getUserId, userId);
        wrapper.in(SysAiChatSessionEntity::getId, idList);
        List<SysAiChatSessionEntity> sessions = baseMapper.selectList(wrapper);
        if (sessions.isEmpty()) {
            return;
        }
        List<Long> ids = sessions.stream().map(SysAiChatSessionEntity::getId).toList();
        messageDao.delete(Wrappers.lambdaQuery(SysAiChatMessageEntity.class)
                .in(SysAiChatMessageEntity::getSessionId, ids)
                .eq(SysAiChatMessageEntity::getUserId, userId));
        baseMapper.delete(Wrappers.lambdaQuery(SysAiChatSessionEntity.class)
                .eq(SysAiChatSessionEntity::getUserId, userId)
                .in(SysAiChatSessionEntity::getId, ids));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long ensureMineSession(Long sessionId, String firstUserMessage) {
        if (sessionId != null) {
            requireMine(sessionId);
            return sessionId;
        }
        return createMine(buildTitle(firstUserMessage)).getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void appendTurn(Long sessionId, String userMessage, String assistantMessage) {
        SysAiChatSessionEntity session = requireMine(sessionId);
        Long userId = SecurityUser.getUserId();
        LocalDateTime now = LocalDateTime.now();

        insertMessage(session.getId(), userId, "user", userMessage);
        if (StrUtil.isNotBlank(assistantMessage)) {
            insertMessage(session.getId(), userId, "assistant", assistantMessage);
        }

        if ("新对话".equals(session.getTitle()) || StrUtil.isBlank(session.getTitle())) {
            session.setTitle(buildTitle(userMessage));
        }
        session.setLastMsgTime(now);
        updateById(session);
    }

    private void insertMessage(Long sessionId, Long userId, String role, String content) {
        SysAiChatMessageEntity msg = new SysAiChatMessageEntity();
        msg.setSessionId(sessionId);
        msg.setUserId(userId);
        msg.setRole(role);
        msg.setContent(content);
        messageDao.insert(msg);
    }

    private SysAiChatSessionEntity requireMine(Long sessionId) {
        if (sessionId == null) {
            throw new ServerException("会话不存在");
        }
        SysAiChatSessionEntity session = baseMapper.selectById(sessionId);
        if (session == null || !SecurityUser.getUserId().equals(session.getUserId())) {
            throw new ServerException("会话不存在或无权访问");
        }
        return session;
    }

    private String buildTitle(String message) {
        String title = StrUtil.trim(StrUtil.blankToDefault(message, "新对话"));
        title = title.replaceAll("\\s+", " ");
        return StrUtil.maxLength(title, 40);
    }
}
