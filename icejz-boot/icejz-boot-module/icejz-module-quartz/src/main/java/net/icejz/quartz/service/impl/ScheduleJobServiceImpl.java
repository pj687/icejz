package net.icejz.quartz.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import jakarta.annotation.PostConstruct;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.quartz.dao.ScheduleJobDao;
import net.icejz.quartz.entity.ScheduleJobEntity;
import net.icejz.quartz.enums.ScheduleStatusEnum;
import net.icejz.quartz.query.ScheduleJobQuery;
import net.icejz.quartz.service.ScheduleJobService;
import net.icejz.quartz.utils.ScheduleUtils;
import net.icejz.quartz.vo.ScheduleJobVO;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 定时任务
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class ScheduleJobServiceImpl extends BaseServiceImpl<ScheduleJobDao, ScheduleJobEntity> implements ScheduleJobService {
    private final Scheduler scheduler;

    /**
     * 启动项目时，初始化定时器
     */
    @PostConstruct
    public void init() throws SchedulerException {
        scheduler.clear();
        List<ScheduleJobEntity> scheduleJobList = baseMapper.selectList(null);
        for (ScheduleJobEntity scheduleJob : scheduleJobList) {
            ScheduleUtils.createScheduleJob(scheduler, scheduleJob);
        }
    }

    @Override
    public PageResult<ScheduleJobVO> page(ScheduleJobQuery query) {
        IPage<ScheduleJobEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), ScheduleJobVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<ScheduleJobEntity> getWrapper(ScheduleJobQuery query) {
        LambdaQueryWrapper<ScheduleJobEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.like(StrUtil.isNotBlank(query.getJobName()), ScheduleJobEntity::getJobName, query.getJobName());
        wrapper.like(StrUtil.isNotBlank(query.getJobGroup()), ScheduleJobEntity::getJobGroup, query.getJobGroup());
        wrapper.eq(query.getStatus() != null, ScheduleJobEntity::getStatus, query.getStatus());

        return wrapper;
    }

    @Override
    public void save(ScheduleJobVO vo) {
        ScheduleJobEntity entity = BeanUtil.copyProperties(vo, ScheduleJobEntity.class);

        entity.setStatus(ScheduleStatusEnum.PAUSE.getValue());
        if (baseMapper.insert(entity) > 0) {
            ScheduleUtils.createScheduleJob(scheduler, entity);
        }
    }

    @Override
    public void update(ScheduleJobVO vo) {
        ScheduleJobEntity entity = BeanUtil.copyProperties(vo, ScheduleJobEntity.class);

        // 更新定时任务
        if (updateById(entity)) {
            ScheduleJobEntity scheduleJob = getById(entity.getId());
            ScheduleUtils.updateSchedulerJob(scheduler, scheduleJob);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        for (Long id : idList) {
            ScheduleJobEntity scheduleJob = getById(id);

            // 删除定时任务
            if (removeById(id)) {
                ScheduleUtils.deleteScheduleJob(scheduler, scheduleJob);
            }
        }
    }

    @Override
    public void run(ScheduleJobVO vo) {
        ScheduleJobEntity scheduleJob = getById(vo.getId());
        if (scheduleJob == null) {
            return;
        }

        ScheduleUtils.run(scheduler, scheduleJob);
    }

    @Override
    public void changeStatus(ScheduleJobVO vo) {
        ScheduleJobEntity scheduleJob = getById(vo.getId());
        if (scheduleJob == null) {
            return;
        }

        // 更新数据
        scheduleJob.setStatus(vo.getStatus());
        updateById(scheduleJob);

        if (ScheduleStatusEnum.PAUSE.getValue() == vo.getStatus()) {
            ScheduleUtils.pauseJob(scheduler, scheduleJob);
        } else if (ScheduleStatusEnum.NORMAL.getValue() == vo.getStatus()) {
            ScheduleUtils.resumeJob(scheduler, scheduleJob);
        }
    }

}