package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysSmsLogEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 短信日志
 *
 * @author ice_jz
 */
@Mapper
public interface SysSmsLogDao extends BaseDao<SysSmsLogEntity> {

}