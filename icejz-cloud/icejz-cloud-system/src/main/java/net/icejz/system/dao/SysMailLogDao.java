package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysMailLogEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 邮件日志
 *
 * @author ice_jz
 */
@Mapper
public interface SysMailLogDao extends BaseDao<SysMailLogEntity> {

}