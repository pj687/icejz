package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysChatScopeOrgEntity;

import java.util.List;

public interface SysChatScopeOrgService extends BaseService<SysChatScopeOrgEntity> {

    void saveOrUpdate(Long roleId, List<Long> orgIdList);

    List<Long> getOrgIdList(Long roleId);

    void deleteByRoleIdList(List<Long> roleIdList);
}
