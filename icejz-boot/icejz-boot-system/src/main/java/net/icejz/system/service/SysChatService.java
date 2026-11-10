package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.system.query.SysChatConversationQuery;
import net.icejz.system.query.SysChatMessageQuery;
import net.icejz.system.vo.*;

import java.util.List;

/**
 * 企业内部聊天
 */
public interface SysChatService {

    PageResult<SysChatConversationVO> conversationPage(SysChatConversationQuery query);

    SysChatConversationVO conversationInfo(Long id);

    SysChatConversationVO createDirect(SysChatDirectVO vo);

    SysChatConversationVO createGroup(SysChatGroupVO vo);

    void addMembers(SysChatMemberUpdateVO vo);

    void removeMembers(SysChatMemberUpdateVO vo);

    void dissolve(Long conversationId);

    PageResult<SysChatMessageVO> messagePage(SysChatMessageQuery query);

    SysChatMessageVO sendMessage(SysChatMessageVO vo);

    void read(Long conversationId);

    void recall(Long messageId);

    Long unreadTotal();

    List<SysChatMemberVO> members(Long conversationId);
}
