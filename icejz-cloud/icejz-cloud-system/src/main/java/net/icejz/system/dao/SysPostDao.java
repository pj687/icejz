package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysPostEntity;
import org.apache.ibatis.annotations.Mapper;

/**
* 岗位管理
*
* @author ice_jz
*/
@Mapper
public interface SysPostDao extends BaseDao<SysPostEntity> {
	
}