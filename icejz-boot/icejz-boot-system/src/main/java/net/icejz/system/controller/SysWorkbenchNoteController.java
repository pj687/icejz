package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.service.SysWorkbenchNoteService;
import net.icejz.system.vo.SysWorkbenchNoteVO;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 工作台日历记事
 */
@RestController
@RequestMapping("sys/workbench/note")
@Tag(name = "工作台记事")
@AllArgsConstructor
public class SysWorkbenchNoteController {
    private final SysWorkbenchNoteService sysWorkbenchNoteService;

    @GetMapping("list")
    @Operation(summary = "我的记事列表")
    public Result<List<SysWorkbenchNoteVO>> list(@RequestParam(required = false) String yearMonth) {
        return Result.ok(sysWorkbenchNoteService.listMine(yearMonth));
    }

    @PostMapping
    @Operation(summary = "保存记事")
    @OperateLog(type = OperateTypeEnum.INSERT)
    public Result<SysWorkbenchNoteVO> save(@RequestBody @Valid SysWorkbenchNoteVO vo) {
        return Result.ok(sysWorkbenchNoteService.saveMine(vo));
    }

    @DeleteMapping
    @Operation(summary = "删除记事")
    @OperateLog(type = OperateTypeEnum.DELETE)
    public Result<String> delete(@RequestBody List<Long> idList) {
        sysWorkbenchNoteService.deleteMine(idList);
        return Result.ok();
    }
}
