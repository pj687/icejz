package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysAiChatSessionEntity;
import net.icejz.system.vo.SysAiChatMessageVO;
import net.icejz.system.vo.SysAiChatSessionVO;

import java.util.List;

/**
 * AI 对话会话
 */
public interface SysAiChatSessionService extends BaseService<SysAiChatSessionEntity> {

    List<SysAiChatSessionVO> listMine();

    List<SysAiChatMessageVO> listMessages(Long sessionId);

    SysAiChatSessionVO createMine(String title);

    void deleteMine(List<Long> idList);

    /**
     * 确保会话存在并归属当前用户；若 sessionId 为空则新建
     */
    Long ensureMineSession(Long sessionId, String firstUserMessage);

    /**
     * 写入一轮对话并刷新会话标题/时间
     */
    void appendTurn(Long sessionId, String userMessage, String assistantMessage);
}
