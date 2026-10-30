package net.icejz.quartz.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import net.icejz.quartz.convert.ScheduleJobLogConvert;
import net.icejz.quartz.entity.ScheduleJobLogEntity;
import net.icejz.quartz.query.ScheduleJobLogQuery;
import net.icejz.quartz.service.ScheduleJobLogService;
import net.icejz.quartz.vo.ScheduleJobLogVO;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 定时任务日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@RestController
@RequestMapping("schedule/log")
@Tag(name = "定时任务日志")
@AllArgsConstructor
public class ScheduleJobLogController {
    private final ScheduleJobLogService scheduleJobLogService;

    @GetMapping("page")
    @Operation(summary = "分页")
    @PreAuthorize("hasAuthority('schedule:log')")
    public Result<PageResult<ScheduleJobLogVO>> page(@ParameterObject @Valid ScheduleJobLogQuery query) {
        PageResult<ScheduleJobLogVO> page = scheduleJobLogService.page(query);

        return Result.ok(page);
    }

    @GetMapping("{id}")
    @Operation(summary = "信息")
    @PreAuthorize("hasAuthority('schedule:log')")
    public Result<ScheduleJobLogVO> get(@PathVariable("id") Long id) {
        ScheduleJobLogEntity entity = scheduleJobLogService.getById(id);

        return Result.ok(ScheduleJobLogConvert.INSTANCE.convert(entity));
    }

}