package net.icejz.system.service;

import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.entity.SysMenuEntity;
import net.icejz.system.vo.SysMenuVO;

import java.util.List;
import java.util.Set;


/**
 * 菜单管理
 * 
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysMenuService extends BaseService<SysMenuEntity> {

	void save(SysMenuVO vo);

	void update(SysMenuVO vo);

	void delete(Long id);

	/**
	 * 菜单列表
	 */
	List<SysMenuVO> getMenuList(Integer type, Integer clientType);

	/**
	 * 用户菜单列表
	 */
	List<SysMenuVO> getUserMenuList(UserDetail user, Integer type, Integer clientType);

	/**
	 * 获取子菜单的数量
	 * @param pid  父菜单ID
	 */
	Long getSubMenuCount(Long pid);

	/**
	 * 获取用户权限列表
	 */
	Set<String> getUserAuthority(UserDetail user);
}
