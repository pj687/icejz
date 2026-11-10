package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysMenuEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 菜单管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysMenuDao extends BaseDao<SysMenuEntity> {

	/**
	 * 查询所有菜单列表
	 */
	List<SysMenuEntity> getMenuList(@Param("type") Integer type, @Param("clientType") Integer clientType);

	/**
	 * 查询用户菜单列表
	 */
	List<SysMenuEntity> getUserMenuList(@Param("userId") Long userId, @Param("type") Integer type,
										@Param("clientType") Integer clientType);

	/**
	 * 查询用户权限列表
	 */
	List<String> getUserAuthorityList(@Param("userId") Long userId);

	/**
	 * 查询所有权限列表
	 */
	List<String> getAuthorityList();

}
