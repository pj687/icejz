package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysChatScopeOrgEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SysChatScopeOrgDao extends BaseDao<SysChatScopeOrgEntity> {

    List<Long> getOrgIdList(@Param("roleId") Long roleId);

    List<Long> getOrgIdListByUserId(@Param("userId") Long userId);
}
