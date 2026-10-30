package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysUserRoleEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 用户角色关系
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysUserRoleDao extends BaseDao<SysUserRoleEntity> {

    /**
     * 角色ID列表
     * @param userId  用户ID
     *
     * @return  返回角色ID列表
     */
    List<Long> getRoleIdList(@Param("userId") Long userId);

    /**
     * 根据角色ID查询对应的用户ID列表
     * @param roleId  角色ID
     *
     * @return  返回用户ID列表
     */
    List<Long> getExistsUserIdList(@Param("roleId") Long roleId);
}