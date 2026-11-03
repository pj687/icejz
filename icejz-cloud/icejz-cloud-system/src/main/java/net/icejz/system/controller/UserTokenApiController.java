package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.system.service.SysUserTokenService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 内部令牌 API（供监控等服务 Feign 调用）
 */
@RestController
@RequestMapping("api/sys/token")
@Tag(name = "用户令牌内部API")
@AllArgsConstructor
public class UserTokenApiController {
    private final SysUserTokenService sysUserTokenService;

    @PostMapping("expire")
    @Operation(summary = "按 accessToken 失效会话")
    public Result<String> expire(@RequestParam("accessToken") String accessToken) {
        sysUserTokenService.expireByAccessToken(accessToken);
        return Result.ok();
    }
}
