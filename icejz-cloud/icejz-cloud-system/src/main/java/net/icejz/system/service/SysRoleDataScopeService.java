package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysRoleDataScopeEntity;

import java.util.List;

/**
 * 角色数据权限
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysRoleDataScopeService extends BaseService<SysRoleDataScopeEntity> {

    /**
     * 保存或修改
     * @param roleId      角色ID
     * @param orgIdList   机构ID列表
     */
    void saveOrUpdate(Long roleId, List<Long> orgIdList);

    /**
     * 根据角色ID，获取机构ID列表
     */
    List<Long> getOrgIdList(Long roleId);

    /**
     * 根据角色id列表，删除角色数据权限关系
     * @param roleIdList 角色id列表
     */
    void deleteByRoleIdList(List<Long> roleIdList);
}