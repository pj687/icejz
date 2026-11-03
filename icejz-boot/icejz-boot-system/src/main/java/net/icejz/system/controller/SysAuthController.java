package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.security.crypto.Sm2Util;
import net.icejz.framework.security.utils.TokenUtils;
import net.icejz.system.cache.SmsSendCache;
import net.icejz.system.service.SysAuthService;
import net.icejz.system.service.SysCaptchaService;
import net.icejz.system.vo.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

/**
 * 认证管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@RestController
@RequestMapping("sys/auth")
@Tag(name = "认证管理")
@RequiredArgsConstructor
public class SysAuthController {
    private final SysCaptchaService sysCaptchaService;
    private final SysAuthService sysAuthService;
    private final SmsSendCache smsSendCache;

    @Value("${icejz.sms.mock:false}")
    private boolean smsMock;

    @GetMapping("captcha")
    @Operation(summary = "验证码")
    public Result<SysCaptchaVO> captcha(@RequestParam(value = "channel", required = false, defaultValue = "pc") String channel) {
        SysCaptchaVO captchaVO = sysCaptchaService.generate(channel);

        return Result.ok(captchaVO);
    }

    @GetMapping("captcha/enabled")
    @Operation(summary = "是否开启验证码")
    public Result<Boolean> captchaEnabled() {
        boolean enabled = sysCaptchaService.isCaptchaEnabled();

        return Result.ok(enabled);
    }

    @PostMapping("captcha/check")
    @Operation(summary = "验证码预校验（滑动拼图松手反馈，不消费）")
    public Result<Boolean> captchaCheck(@RequestBody SysCaptchaCheckVO body) {
        boolean ok = sysCaptchaService.check(body.getKey(), body.getCaptcha());
        return Result.ok(ok);
    }

    @GetMapping("public-key")
    @Operation(summary = "SM2公钥")
    public Result<String> publicKey() {
        return Result.ok(Sm2Util.getPublicKeyHex());
    }

    @PostMapping("login")
    @Operation(summary = "账号密码登录")
    public Result<SysUserTokenVO> login(@RequestBody SysAccountLoginVO login) {
        SysUserTokenVO token = sysAuthService.loginByAccount(login);

        return Result.ok(token);
    }

    @PostMapping("send/code")
    @Operation(summary = "发送短信验证码")
    public Result<String> sendCode(@RequestBody SysSendCodeVO send) {
        boolean flag = sysAuthService.sendCode(send);
        if (!flag) {
            return Result.error("短信发送失败！");
        }

        // 模拟模式：回传验证码（真实短信场景不返回）
        if (smsMock) {
            return Result.ok(smsSendCache.getCode(send.getMobile()));
        }

        return Result.ok();
    }

    @PostMapping("mobile")
    @Operation(summary = "手机号登录")
    public Result<SysUserTokenVO> mobile(@RequestBody SysMobileLoginVO login) {
        SysUserTokenVO token = sysAuthService.loginByMobile(login);

        return Result.ok(token);
    }

    @PostMapping("third")
    @Operation(summary = "第三方登录")
    public Result<SysUserTokenVO> third(@RequestBody SysThirdCallbackVO login) {
        SysUserTokenVO token = sysAuthService.loginByThird(login);

        return Result.ok(token);
    }

    @PostMapping("token")
    @Operation(summary = "获取AccessToken")
    public Result<AccessTokenVO> token(String refreshToken) {
        AccessTokenVO token = sysAuthService.getAccessToken(refreshToken);

        return Result.ok(token);
    }

    @PostMapping("logout")
    @Operation(summary = "退出")
    public Result<String> logout(HttpServletRequest request) {
        sysAuthService.logout(TokenUtils.getAccessToken(request));

        return Result.ok();
    }
}
