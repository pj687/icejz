package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.query.SysMessageMyQuery;
import net.icejz.system.query.SysMessageQuery;
import net.icejz.system.service.SysMessageService;
import net.icejz.system.vo.SysMessageMyVO;
import net.icejz.system.vo.SysMessageVO;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 站内消息
 */
@RestController
@RequestMapping("sys/message")
@Tag(name = "站内消息")
@AllArgsConstructor
public class SysMessageController {
    private final SysMessageService sysMessageService;

    @GetMapping("my/page")
    @Operation(summary = "我的消息分页")
    public Result<PageResult<SysMessageMyVO>> myPage(@ParameterObject @Valid SysMessageMyQuery query) {
        return Result.ok(sysMessageService.myPage(query));
    }

    @GetMapping("my/unread-count")
    @Operation(summary = "未读数量")
    public Result<Long> unreadCount() {
        return Result.ok(sysMessageService.unreadCount());
    }

    @GetMapping("my/latest")
    @Operation(summary = "最近消息")
    public Result<List<SysMessageMyVO>> latest(@RequestParam(defaultValue = "5") Integer limit) {
        return Result.ok(sysMessageService.latest(limit));
    }

    @GetMapping("my/{id}")
    @Operation(summary = "我的消息详情（自动已读）")
    public Result<SysMessageMyVO> myInfo(@PathVariable("id") Long id) {
        return Result.ok(sysMessageService.myInfo(id));
    }

    @PutMapping("my/{id}/read")
    @Operation(summary = "标记已读")
    public Result<String> read(@PathVariable("id") Long id) {
        sysMessageService.read(id);
        return Result.ok();
    }

    @PutMapping("my/read-all")
    @Operation(summary = "全部已读")
    public Result<String> readAll() {
        sysMessageService.readAll();
        return Result.ok();
    }

    @GetMapping("page")
    @Operation(summary = "分页")
    @PreAuthorize("hasAuthority('sys:message:page')")
    public Result<PageResult<SysMessageVO>> page(@ParameterObject @Valid SysMessageQuery query) {
        return Result.ok(sysMessageService.page(query));
    }

    @GetMapping("{id}")
    @Operation(summary = "信息")
    @PreAuthorize("hasAuthority('sys:message:info')")
    public Result<SysMessageVO> get(@PathVariable("id") Long id) {
        return Result.ok(sysMessageService.getInfo(id));
    }

    @PostMapping
    @Operation(summary = "发送消息")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:message:save')")
    public Result<String> send(@RequestBody @Valid SysMessageVO vo) {
        sysMessageService.send(vo);
        return Result.ok();
    }

    @DeleteMapping
    @Operation(summary = "删除")
    @OperateLog(type = OperateTypeEnum.DELETE)
    @PreAuthorize("hasAuthority('sys:message:delete')")
    public Result<String> delete(@RequestBody List<Long> idList) {
        sysMessageService.delete(idList);
        return Result.ok();
    }
}
