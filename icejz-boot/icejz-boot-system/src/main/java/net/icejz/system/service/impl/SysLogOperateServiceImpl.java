package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.thread.ThreadUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.icejz.framework.common.cache.RedisCache;
import net.icejz.framework.common.cache.RedisKeys;
import net.icejz.framework.common.utils.ExceptionUtils;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.operatelog.dto.OperateLogDTO;
import net.icejz.system.dao.SysLogOperateDao;
import net.icejz.system.entity.SysLogOperateEntity;
import net.icejz.system.query.SysLogOperateQuery;
import net.icejz.system.service.SysLogOperateService;
import net.icejz.system.vo.SysLogOperateVO;
import org.redisson.RedissonShutdownException;
import org.springframework.dao.InvalidDataAccessApiUsageException;
import org.springframework.stereotype.Service;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 操作日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysLogOperateServiceImpl extends BaseServiceImpl<SysLogOperateDao, SysLogOperateEntity> implements SysLogOperateService {
    private final RedisCache redisCache;

    private final AtomicBoolean running = new AtomicBoolean(true);
    private ScheduledExecutorService scheduledService;

    @Override
    public PageResult<SysLogOperateVO> page(SysLogOperateQuery query) {
        IPage<SysLogOperateEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), SysLogOperateVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<SysLogOperateEntity> getWrapper(SysLogOperateQuery query) {
        LambdaQueryWrapper<SysLogOperateEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(query.getStatus() != null, SysLogOperateEntity::getStatus, query.getStatus());
        wrapper.like(StrUtil.isNotBlank(query.getRealName()), SysLogOperateEntity::getRealName, query.getRealName());
        wrapper.like(StrUtil.isNotBlank(query.getModule()), SysLogOperateEntity::getModule, query.getModule());
        wrapper.like(StrUtil.isNotBlank(query.getReqUri()), SysLogOperateEntity::getReqUri, query.getReqUri());
        wrapper.orderByDesc(SysLogOperateEntity::getId);
        return wrapper;
    }

    /**
     * 启动项目时，从Redis队列获取操作日志并保存
     */
    @PostConstruct
    public void saveLog() {
        scheduledService = ThreadUtil.createScheduledExecutor(1);

        // 每隔10秒钟，执行一次
        scheduledService.scheduleWithFixedDelay(() -> {
            if (!running.get()) {
                return;
            }
            try {
                String key = RedisKeys.getLogKey();
                // 每次插入10条
                int count = 10;
                for (int i = 0; i < count; i++) {
                    if (!running.get()) {
                        return;
                    }
                    OperateLogDTO logDto = (OperateLogDTO) redisCache.rightPop(key);
                    if (logDto == null) {
                        return;
                    }

                    SysLogOperateEntity entity = BeanUtil.copyProperties(logDto, SysLogOperateEntity.class);
                    baseMapper.insert(entity);
                }
            } catch (Exception e) {
                if (isShutdownRelated(e)) {
                    // 应用关闭时 Redis/Redisson 已先销毁，忽略即可
                    running.set(false);
                    return;
                }
                log.error("SysLogOperateServiceImpl.saveLog Error：{}", ExceptionUtils.getExceptionMessage(e));
            }
        }, 1, 10, TimeUnit.SECONDS);
    }

    @PreDestroy
    public void destroy() {
        running.set(false);
        if (scheduledService != null) {
            scheduledService.shutdownNow();
            try {
                scheduledService.awaitTermination(3, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private boolean isShutdownRelated(Throwable e) {
        Throwable cursor = e;
        while (cursor != null) {
            if (cursor instanceof RedissonShutdownException) {
                return true;
            }
            if (cursor instanceof InvalidDataAccessApiUsageException
                    && cursor.getMessage() != null
                    && cursor.getMessage().contains("Redisson is shutdown")) {
                return true;
            }
            if (cursor.getMessage() != null && cursor.getMessage().contains("Redisson is shutdown")) {
                return true;
            }
            cursor = cursor.getCause();
        }
        return false;
    }
}
