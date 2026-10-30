package net.icejz.quartz.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.quartz.entity.ScheduleJobEntity;
import net.icejz.quartz.query.ScheduleJobQuery;
import net.icejz.quartz.vo.ScheduleJobVO;

import java.util.List;

/**
 * 定时任务
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface ScheduleJobService extends BaseService<ScheduleJobEntity> {

    PageResult<ScheduleJobVO> page(ScheduleJobQuery query);

    void save(ScheduleJobVO vo);

    void update(ScheduleJobVO vo);

    void delete(List<Long> idList);

    void run(ScheduleJobVO vo);

    void changeStatus(ScheduleJobVO vo);
}