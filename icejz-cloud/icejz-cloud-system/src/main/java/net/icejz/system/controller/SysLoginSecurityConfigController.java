package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.service.SysLoginSecurityConfigService;
import net.icejz.system.vo.SysLoginSecurityConfigVO;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * 登录安全配置
 */
@RestController
@RequestMapping("sys/login/security")
@Tag(name = "登录安全配置")
@AllArgsConstructor
public class SysLoginSecurityConfigController {
    private final SysLoginSecurityConfigService sysLoginSecurityConfigService;

    @GetMapping
    @Operation(summary = "获取登录安全配置")
    @PreAuthorize("hasAuthority('sys:login:security')")
    public Result<SysLoginSecurityConfigVO> get() {
        return Result.ok(sysLoginSecurityConfigService.getConfig());
    }

    @PutMapping
    @Operation(summary = "保存登录安全配置")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:login:security')")
    public Result<String> save(@RequestBody SysLoginSecurityConfigVO vo) {
        sysLoginSecurityConfigService.saveConfig(vo);
        return Result.ok();
    }
}
