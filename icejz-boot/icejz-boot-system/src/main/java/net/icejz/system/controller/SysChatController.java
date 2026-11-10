package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.query.SysChatAllowQuery;
import net.icejz.system.query.SysChatConversationQuery;
import net.icejz.system.query.SysChatMessageQuery;
import net.icejz.system.query.SysChatPeerQuery;
import net.icejz.system.service.SysChatAclService;
import net.icejz.system.service.SysChatService;
import net.icejz.system.vo.*;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 企业内部聊天
 */
@RestController
@RequestMapping("sys/chat")
@Tag(name = "即时通讯")
@AllArgsConstructor
public class SysChatController {
    private final SysChatService sysChatService;
    private final SysChatAclService sysChatAclService;

    @GetMapping("conversation/page")
    @Operation(summary = "会话分页")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<PageResult<SysChatConversationVO>> conversationPage(@ParameterObject @Valid SysChatConversationQuery query) {
        return Result.ok(sysChatService.conversationPage(query));
    }

    @GetMapping("conversation/{id}")
    @Operation(summary = "会话详情")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<SysChatConversationVO> conversationInfo(@PathVariable("id") Long id) {
        return Result.ok(sysChatService.conversationInfo(id));
    }

    @GetMapping("conversation/{id}/members")
    @Operation(summary = "会话成员")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<List<SysChatMemberVO>> members(@PathVariable("id") Long id) {
        return Result.ok(sysChatService.members(id));
    }

    @PostMapping("conversation/direct")
    @Operation(summary = "发起单聊")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:chat:direct')")
    public Result<SysChatConversationVO> createDirect(@RequestBody @Valid SysChatDirectVO vo) {
        return Result.ok(sysChatService.createDirect(vo));
    }

    @PostMapping("conversation/group")
    @Operation(summary = "创建群聊")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:chat:group')")
    public Result<SysChatConversationVO> createGroup(@RequestBody @Valid SysChatGroupVO vo) {
        return Result.ok(sysChatService.createGroup(vo));
    }

    @PostMapping("conversation/members")
    @Operation(summary = "添加成员")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<String> addMembers(@RequestBody @Valid SysChatMemberUpdateVO vo) {
        sysChatService.addMembers(vo);
        return Result.ok();
    }

    @DeleteMapping("conversation/members")
    @Operation(summary = "移除成员")
    @OperateLog(type = OperateTypeEnum.DELETE)
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<String> removeMembers(@RequestBody @Valid SysChatMemberUpdateVO vo) {
        sysChatService.removeMembers(vo);
        return Result.ok();
    }

    @PutMapping("conversation/{id}/dissolve")
    @Operation(summary = "解散会话")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<String> dissolve(@PathVariable("id") Long id) {
        // 群主/管理员或 sys:chat:manage 在 Service 内校验
        sysChatService.dissolve(id);
        return Result.ok();
    }

    @PutMapping("conversation/{id}/read")
    @Operation(summary = "会话已读")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<String> read(@PathVariable("id") Long id) {
        sysChatService.read(id);
        return Result.ok();
    }

    @GetMapping("message/page")
    @Operation(summary = "消息历史")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<PageResult<SysChatMessageVO>> messagePage(@ParameterObject @Valid SysChatMessageQuery query) {
        return Result.ok(sysChatService.messagePage(query));
    }

    @PostMapping("message")
    @Operation(summary = "发送消息")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<SysChatMessageVO> send(@RequestBody @Valid SysChatMessageVO vo) {
        return Result.ok(sysChatService.sendMessage(vo));
    }

    @PutMapping("message/{id}/recall")
    @Operation(summary = "撤回消息")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<String> recall(@PathVariable("id") Long id) {
        sysChatService.recall(id);
        return Result.ok();
    }

    @GetMapping("unread-count")
    @Operation(summary = "聊天未读总数")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<Long> unreadCount() {
        return Result.ok(sysChatService.unreadTotal());
    }

    @GetMapping("peer/page")
    @Operation(summary = "可选人分页（ACL过滤）")
    @PreAuthorize("hasAuthority('sys:chat:page')")
    public Result<PageResult<SysChatPeerVO>> peerPage(@ParameterObject @Valid SysChatPeerQuery query) {
        return Result.ok(sysChatAclService.peerPage(query));
    }

    @GetMapping("allow/page")
    @Operation(summary = "白名单分页")
    @PreAuthorize("hasAuthority('sys:chat:acl')")
    public Result<PageResult<SysChatAllowVO>> allowPage(@ParameterObject @Valid SysChatAllowQuery query) {
        return Result.ok(sysChatAclService.allowPage(query));
    }

    @PostMapping("allow")
    @Operation(summary = "新增白名单")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:chat:acl')")
    public Result<String> saveAllow(@RequestBody @Valid SysChatAllowVO vo) {
        sysChatAclService.saveAllow(vo);
        return Result.ok();
    }

    @PutMapping("allow")
    @Operation(summary = "修改白名单")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:chat:acl')")
    public Result<String> updateAllow(@RequestBody @Valid SysChatAllowVO vo) {
        sysChatAclService.updateAllow(vo);
        return Result.ok();
    }

    @DeleteMapping("allow")
    @Operation(summary = "删除白名单")
    @OperateLog(type = OperateTypeEnum.DELETE)
    @PreAuthorize("hasAuthority('sys:chat:acl')")
    public Result<String> deleteAllow(@RequestBody List<Long> idList) {
        sysChatAclService.deleteAllow(idList);
        return Result.ok();
    }
}
