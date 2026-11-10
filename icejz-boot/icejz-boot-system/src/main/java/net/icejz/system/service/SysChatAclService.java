package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.system.query.SysChatAllowQuery;
import net.icejz.system.query.SysChatPeerQuery;
import net.icejz.system.vo.SysChatAllowVO;
import net.icejz.system.vo.SysChatPeerVO;

import java.util.Collection;
import java.util.List;
import java.util.Set;

/**
 * 即时通讯 ACL
 */
public interface SysChatAclService {

    boolean canChat(Long fromUserId, Long toUserId);

    void assertCanChat(Long fromUserId, Long toUserId);

    void assertCanChatAll(Long fromUserId, Collection<Long> toUserIds);

    /**
     * null 表示全部机构；空集合表示不可跨任何机构（仅白名单用户）
     */
    Set<Long> listAllowedOrgIds(Long userId);

    PageResult<SysChatPeerVO> peerPage(SysChatPeerQuery query);

    PageResult<SysChatAllowVO> allowPage(SysChatAllowQuery query);

    void saveAllow(SysChatAllowVO vo);

    void updateAllow(SysChatAllowVO vo);

    void deleteAllow(List<Long> idList);
}
