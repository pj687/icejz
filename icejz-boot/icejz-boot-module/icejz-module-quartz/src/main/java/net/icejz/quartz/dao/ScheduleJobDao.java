package net.icejz.quartz.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.quartz.entity.ScheduleJobEntity;
import org.apache.ibatis.annotations.Mapper;

/**
* 定时任务
*
* @author ice_jz
*/
@Mapper
public interface ScheduleJobDao extends BaseDao<ScheduleJobEntity> {
	
}