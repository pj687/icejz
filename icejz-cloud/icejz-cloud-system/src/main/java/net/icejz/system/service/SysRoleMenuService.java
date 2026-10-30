package net.icejz.system.service;


import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.system.entity.SysRoleMenuEntity;

import java.util.List;


/**
 * 角色与菜单对应关系
 * 
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysRoleMenuService extends BaseService<SysRoleMenuEntity> {

	/**
	 * 根据角色ID，获取菜单ID列表
	 */
	List<Long> getMenuIdList(Long roleId);

	/**
	 * 保存或修改
	 * @param roleId      角色ID
	 * @param menuIdList  菜单ID列表
	 */
	void saveOrUpdate(Long roleId, List<Long> menuIdList);

	/**
	 * 根据角色id列表，删除角色菜单关系
	 * @param roleIdList 角色id列表
	 */
	void deleteByRoleIdList(List<Long> roleIdList);

	/**
	 * 根据菜单id，删除角色菜单关系
	 * @param menuId 菜单id
	 */
	void deleteByMenuId(Long menuId);
}