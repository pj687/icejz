package net.icejz.quartz.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.quartz.entity.ScheduleJobLogEntity;
import net.icejz.quartz.query.ScheduleJobLogQuery;
import net.icejz.quartz.vo.ScheduleJobLogVO;

/**
 * 定时任务日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface ScheduleJobLogService extends BaseService<ScheduleJobLogEntity> {

    PageResult<ScheduleJobLogVO> page(ScheduleJobLogQuery query);

}