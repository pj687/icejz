package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.service.SysAiChatSessionService;
import net.icejz.system.vo.SysAiChatMessageVO;
import net.icejz.system.vo.SysAiChatSessionVO;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * AI 对话历史
 */
@RestController
@RequestMapping("sys/ai/chat")
@Tag(name = "AI对话历史")
@AllArgsConstructor
public class SysAiChatSessionController {
    private final SysAiChatSessionService sysAiChatSessionService;

    @GetMapping("session/list")
    @Operation(summary = "我的会话列表")
    public Result<List<SysAiChatSessionVO>> sessionList() {
        return Result.ok(sysAiChatSessionService.listMine());
    }

    @GetMapping("session/{id}/messages")
    @Operation(summary = "会话消息")
    public Result<List<SysAiChatMessageVO>> messages(@PathVariable("id") Long id) {
        return Result.ok(sysAiChatSessionService.listMessages(id));
    }

    @PostMapping("session")
    @Operation(summary = "新建会话")
    @OperateLog(type = OperateTypeEnum.INSERT)
    public Result<SysAiChatSessionVO> create(@RequestBody(required = false) Map<String, String> body) {
        String title = body == null ? null : body.get("title");
        return Result.ok(sysAiChatSessionService.createMine(title));
    }

    @DeleteMapping("session")
    @Operation(summary = "删除会话")
    @OperateLog(type = OperateTypeEnum.DELETE)
    public Result<String> delete(@RequestBody List<Long> idList) {
        sysAiChatSessionService.deleteMine(idList);
        return Result.ok();
    }
}
