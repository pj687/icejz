package net.icejz.system.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysRoleEntity;
import net.icejz.system.query.SysRoleQuery;
import net.icejz.system.vo.SysRoleDataScopeVO;
import net.icejz.system.vo.SysRoleVO;

import java.util.List;

/**
 * 角色
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysRoleService extends BaseService<SysRoleEntity> {

    PageResult<SysRoleVO> page(SysRoleQuery query);

    List<SysRoleVO> getList(SysRoleQuery query);

    void save(SysRoleVO vo);

    void update(SysRoleVO vo);

    void dataScope(SysRoleDataScopeVO vo);

    void delete(List<Long> idList);

    /**
     * 获取角色名称列表
     *
     * @param idList 角色ID列表
     * @return 角色名称列表
     */
    List<String> getNameList(List<Long> idList);
}
