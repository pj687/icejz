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
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.dao.SysChatAllowDao;
import net.icejz.system.dao.SysChatScopeOrgDao;
import net.icejz.system.dao.SysOrgDao;
import net.icejz.system.dao.SysRoleDao;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysChatAllowEntity;
import net.icejz.system.entity.SysOrgEntity;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.enums.DataScopeEnum;
import net.icejz.system.enums.SuperAdminEnum;
import net.icejz.system.query.SysChatAllowQuery;
import net.icejz.system.query.SysChatPeerQuery;
import net.icejz.system.service.SysChatAclService;
import net.icejz.system.service.SysOrgService;
import net.icejz.system.vo.SysChatAllowVO;
import net.icejz.system.vo.SysChatPeerVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class SysChatAclServiceImpl implements SysChatAclService {

    private static final int ALLOW_USER_USER = 1;
    private static final int ALLOW_ORG_ORG = 2;
    private static final int ALLOW_USER_ORG = 3;

    private final SysChatAllowDao allowDao;
    private final SysChatScopeOrgDao chatScopeOrgDao;
    private final SysRoleDao sysRoleDao;
    private final SysUserDao sysUserDao;
    private final SysOrgDao sysOrgDao;
    private final SysOrgService sysOrgService;

    @Override
    public boolean canChat(Long fromUserId, Long toUserId) {
        if (fromUserId == null || toUserId == null) {
            return false;
        }
        if (Objects.equals(fromUserId, toUserId)) {
            return true;
        }
        UserDetail current = SecurityUser.getUser();
        if (current != null && Objects.equals(current.getId(), fromUserId) && bypass(current)) {
            return true;
        }
        SysUserEntity from = sysUserDao.selectById(fromUserId);
        SysUserEntity to = sysUserDao.selectById(toUserId);
        if (from == null || to == null) {
            return false;
        }
        if (Objects.equals(from.getSuperAdmin(), SuperAdminEnum.YES.getValue())) {
            return true;
        }
        if (hitWhitelist(from, to)) {
            return true;
        }
        Set<Long> allowedOrgs = listAllowedOrgIds(fromUserId);
        if (allowedOrgs == null) {
            return true;
        }
        return to.getOrgId() != null && allowedOrgs.contains(to.getOrgId());
    }

    @Override
    public void assertCanChat(Long fromUserId, Long toUserId) {
        if (!canChat(fromUserId, toUserId)) {
            throw new ServerException("按企业聊天规则，你不能与该用户沟通");
        }
    }

    @Override
    public void assertCanChatAll(Long fromUserId, Collection<Long> toUserIds) {
        if (CollUtil.isEmpty(toUserIds)) {
            return;
        }
        for (Long toUserId : toUserIds) {
            if (toUserId == null || Objects.equals(fromUserId, toUserId)) {
                continue;
            }
            assertCanChat(fromUserId, toUserId);
        }
    }

    @Override
    public Set<Long> listAllowedOrgIds(Long userId) {
        Integer chatScope = sysRoleDao.getChatScopeByUserId(userId);
        if (chatScope == null || Objects.equals(chatScope, DataScopeEnum.ALL.getValue())) {
            return null;
        }
        SysUserEntity user = sysUserDao.selectById(userId);
        Long orgId = user == null ? null : user.getOrgId();
        Set<Long> orgIds = new HashSet<>();
        if (Objects.equals(chatScope, DataScopeEnum.ORG_AND_CHILD.getValue())) {
            if (orgId != null) {
                orgIds.addAll(sysOrgService.getSubOrgIdList(orgId));
            }
            // 多角色时 custom 机构也并入
            orgIds.addAll(Optional.ofNullable(chatScopeOrgDao.getOrgIdListByUserId(userId)).orElse(List.of()));
        } else if (Objects.equals(chatScope, DataScopeEnum.ORG_ONLY.getValue())) {
            if (orgId != null) {
                orgIds.add(orgId);
            }
            orgIds.addAll(Optional.ofNullable(chatScopeOrgDao.getOrgIdListByUserId(userId)).orElse(List.of()));
        } else if (Objects.equals(chatScope, DataScopeEnum.CUSTOM.getValue())) {
            orgIds.addAll(Optional.ofNullable(chatScopeOrgDao.getOrgIdListByUserId(userId)).orElse(List.of()));
        } else {
            // SELF 或其他：仅本机构
            if (orgId != null) {
                orgIds.add(orgId);
            }
        }
        applyWhitelistOrgs(userId, orgId, orgIds);
        return orgIds;
    }

    @Override
    public PageResult<SysChatPeerVO> peerPage(SysChatPeerQuery query) {
        UserDetail me = SecurityUser.getUser();
        if (me == null) {
            throw new ServerException("未登录");
        }
        Set<Long> allowedOrgs = listAllowedOrgIds(me.getId());
        Set<Long> extraUserIds = listWhitelistPeerUserIds(me.getId(), me.getOrgId());

        LambdaQueryWrapper<SysUserEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.ne(SysUserEntity::getId, me.getId());
        wrapper.like(StrUtil.isNotBlank(query.getUsername()), SysUserEntity::getUsername, query.getUsername());
        wrapper.like(StrUtil.isNotBlank(query.getMobile()), SysUserEntity::getMobile, query.getMobile());
        wrapper.like(StrUtil.isNotBlank(query.getRealName()), SysUserEntity::getRealName, query.getRealName());

        if (CollUtil.isNotEmpty(query.getOrgId())) {
            // 前端机构树筛选与 ACL 取交集
            if (allowedOrgs == null) {
                wrapper.in(SysUserEntity::getOrgId, query.getOrgId());
            } else {
                Set<Long> intersect = query.getOrgId().stream().filter(allowedOrgs::contains).collect(Collectors.toSet());
                if (intersect.isEmpty() && extraUserIds.isEmpty()) {
                    return new PageResult<>(List.of(), 0);
                }
                if (!intersect.isEmpty() && !extraUserIds.isEmpty()) {
                    wrapper.and(w -> w.in(SysUserEntity::getOrgId, intersect).or().in(SysUserEntity::getId, extraUserIds));
                } else if (!intersect.isEmpty()) {
                    wrapper.in(SysUserEntity::getOrgId, intersect);
                } else {
                    wrapper.in(SysUserEntity::getId, extraUserIds);
                }
            }
        } else if (allowedOrgs != null) {
            if (allowedOrgs.isEmpty() && extraUserIds.isEmpty()) {
                return new PageResult<>(List.of(), 0);
            }
            if (!allowedOrgs.isEmpty() && !extraUserIds.isEmpty()) {
                wrapper.and(w -> w.in(SysUserEntity::getOrgId, allowedOrgs).or().in(SysUserEntity::getId, extraUserIds));
            } else if (!allowedOrgs.isEmpty()) {
                wrapper.in(SysUserEntity::getOrgId, allowedOrgs);
            } else {
                wrapper.in(SysUserEntity::getId, extraUserIds);
            }
        }

        wrapper.orderByDesc(SysUserEntity::getId);
        IPage<SysUserEntity> page = sysUserDao.selectPage(new Page<>(query.getPage(), query.getLimit()), wrapper);
        Set<Long> orgIds = page.getRecords().stream().map(SysUserEntity::getOrgId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, String> orgNameMap = loadOrgNames(orgIds);
        List<SysChatPeerVO> list = page.getRecords().stream().map(u -> {
            SysChatPeerVO vo = BeanUtil.copyProperties(u, SysChatPeerVO.class);
            vo.setOrgName(orgNameMap.get(u.getOrgId()));
            return vo;
        }).collect(Collectors.toList());
        return new PageResult<>(list, page.getTotal());
    }

    @Override
    public PageResult<SysChatAllowVO> allowPage(SysChatAllowQuery query) {
        LambdaQueryWrapper<SysChatAllowEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(query.getType() != null, SysChatAllowEntity::getType, query.getType());
        wrapper.eq(query.getStatus() != null, SysChatAllowEntity::getStatus, query.getStatus());
        wrapper.orderByDesc(SysChatAllowEntity::getId);
        IPage<SysChatAllowEntity> page = allowDao.selectPage(new Page<>(query.getPage(), query.getLimit()), wrapper);
        List<SysChatAllowVO> list = page.getRecords().stream().map(this::toAllowVO).collect(Collectors.toList());
        return new PageResult<>(list, page.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveAllow(SysChatAllowVO vo) {
        validateAllow(vo);
        SysChatAllowEntity entity = BeanUtil.copyProperties(vo, SysChatAllowEntity.class);
        if (entity.getStatus() == null) {
            entity.setStatus(1);
        }
        allowDao.insert(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateAllow(SysChatAllowVO vo) {
        if (vo.getId() == null) {
            throw new ServerException("ID不能为空");
        }
        validateAllow(vo);
        SysChatAllowEntity entity = BeanUtil.copyProperties(vo, SysChatAllowEntity.class);
        allowDao.updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteAllow(List<Long> idList) {
        if (CollUtil.isEmpty(idList)) {
            return;
        }
        allowDao.deleteBatchIds(idList);
    }

    private boolean bypass(UserDetail user) {
        if (user.getSuperAdmin() != null && Objects.equals(user.getSuperAdmin(), SuperAdminEnum.YES.getValue())) {
            return true;
        }
        Set<String> set = user.getAuthoritySet();
        return set != null && set.contains("sys:chat:manage");
    }

    private boolean hitWhitelist(SysUserEntity from, SysUserEntity to) {
        List<SysChatAllowEntity> rules = allowDao.selectList(new LambdaQueryWrapper<SysChatAllowEntity>()
                .eq(SysChatAllowEntity::getStatus, 1));
        if (CollUtil.isEmpty(rules)) {
            return false;
        }
        Long fromId = from.getId();
        Long toId = to.getId();
        Long fromOrg = from.getOrgId();
        Long toOrg = to.getOrgId();
        for (SysChatAllowEntity rule : rules) {
            Integer type = rule.getType();
            Long src = rule.getSrcId();
            Long dst = rule.getDstId();
            if (Objects.equals(type, ALLOW_USER_USER)) {
                if ((Objects.equals(src, fromId) && Objects.equals(dst, toId))
                        || (Objects.equals(src, toId) && Objects.equals(dst, fromId))) {
                    return true;
                }
            } else if (Objects.equals(type, ALLOW_ORG_ORG)) {
                if (fromOrg != null && toOrg != null
                        && ((Objects.equals(src, fromOrg) && Objects.equals(dst, toOrg))
                        || (Objects.equals(src, toOrg) && Objects.equals(dst, fromOrg)))) {
                    return true;
                }
            } else if (Objects.equals(type, ALLOW_USER_ORG)) {
                if ((Objects.equals(src, fromId) && Objects.equals(dst, toOrg))
                        || (Objects.equals(src, toId) && Objects.equals(dst, fromOrg))) {
                    return true;
                }
            }
        }
        return false;
    }

    private void applyWhitelistOrgs(Long userId, Long myOrgId, Set<Long> orgIds) {
        List<SysChatAllowEntity> rules = allowDao.selectList(new LambdaQueryWrapper<SysChatAllowEntity>()
                .eq(SysChatAllowEntity::getStatus, 1));
        for (SysChatAllowEntity rule : rules) {
            if (Objects.equals(rule.getType(), ALLOW_ORG_ORG) && myOrgId != null) {
                if (Objects.equals(rule.getSrcId(), myOrgId)) {
                    orgIds.add(rule.getDstId());
                } else if (Objects.equals(rule.getDstId(), myOrgId)) {
                    orgIds.add(rule.getSrcId());
                }
            } else if (Objects.equals(rule.getType(), ALLOW_USER_ORG) && Objects.equals(rule.getSrcId(), userId)) {
                orgIds.add(rule.getDstId());
            }
        }
    }

    private Set<Long> listWhitelistPeerUserIds(Long userId, Long myOrgId) {
        Set<Long> userIds = new HashSet<>();
        List<SysChatAllowEntity> rules = allowDao.selectList(new LambdaQueryWrapper<SysChatAllowEntity>()
                .eq(SysChatAllowEntity::getStatus, 1));
        for (SysChatAllowEntity rule : rules) {
            if (Objects.equals(rule.getType(), ALLOW_USER_USER)) {
                if (Objects.equals(rule.getSrcId(), userId)) {
                    userIds.add(rule.getDstId());
                } else if (Objects.equals(rule.getDstId(), userId)) {
                    userIds.add(rule.getSrcId());
                }
            } else if (Objects.equals(rule.getType(), ALLOW_USER_ORG) && myOrgId != null
                    && Objects.equals(rule.getDstId(), myOrgId)) {
                userIds.add(rule.getSrcId());
            }
        }
        return userIds;
    }

    private void validateAllow(SysChatAllowVO vo) {
        if (!List.of(ALLOW_USER_USER, ALLOW_ORG_ORG, ALLOW_USER_ORG).contains(vo.getType())) {
            throw new ServerException("白名单类型不正确");
        }
        if (Objects.equals(vo.getSrcId(), vo.getDstId()) && Objects.equals(vo.getType(), ALLOW_USER_USER)) {
            throw new ServerException("不能配置与自己的白名单");
        }
        if (Objects.equals(vo.getType(), ALLOW_USER_USER) || Objects.equals(vo.getType(), ALLOW_USER_ORG)) {
            if (sysUserDao.selectById(vo.getSrcId()) == null) {
                throw new ServerException("源用户不存在");
            }
        }
        if (Objects.equals(vo.getType(), ALLOW_USER_USER)) {
            if (sysUserDao.selectById(vo.getDstId()) == null) {
                throw new ServerException("目标用户不存在");
            }
        }
        if (Objects.equals(vo.getType(), ALLOW_ORG_ORG)) {
            if (sysOrgDao.selectById(vo.getSrcId()) == null || sysOrgDao.selectById(vo.getDstId()) == null) {
                throw new ServerException("机构不存在");
            }
        }
        if (Objects.equals(vo.getType(), ALLOW_USER_ORG)) {
            if (sysOrgDao.selectById(vo.getDstId()) == null) {
                throw new ServerException("目标机构不存在");
            }
        }
    }

    private SysChatAllowVO toAllowVO(SysChatAllowEntity entity) {
        SysChatAllowVO vo = BeanUtil.copyProperties(entity, SysChatAllowVO.class);
        if (Objects.equals(entity.getType(), ALLOW_USER_USER)) {
            vo.setSrcName(userLabel(entity.getSrcId()));
            vo.setDstName(userLabel(entity.getDstId()));
        } else if (Objects.equals(entity.getType(), ALLOW_ORG_ORG)) {
            vo.setSrcName(orgLabel(entity.getSrcId()));
            vo.setDstName(orgLabel(entity.getDstId()));
        } else if (Objects.equals(entity.getType(), ALLOW_USER_ORG)) {
            vo.setSrcName(userLabel(entity.getSrcId()));
            vo.setDstName(orgLabel(entity.getDstId()));
        }
        return vo;
    }

    private String userLabel(Long id) {
        SysUserEntity u = sysUserDao.selectById(id);
        if (u == null) {
            return String.valueOf(id);
        }
        return StrUtil.blankToDefault(u.getRealName(), u.getUsername());
    }

    private String orgLabel(Long id) {
        SysOrgEntity org = sysOrgDao.selectById(id);
        return org == null ? String.valueOf(id) : org.getName();
    }

    private Map<Long, String> loadOrgNames(Set<Long> orgIds) {
        if (CollUtil.isEmpty(orgIds)) {
            return Map.of();
        }
        return sysOrgDao.selectBatchIds(orgIds).stream()
                .collect(Collectors.toMap(SysOrgEntity::getId, SysOrgEntity::getName, (a, b) -> a));
    }
}
