package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import net.icejz.api.module.system.SmsApi;
import net.icejz.framework.common.constant.Constant;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.HttpContextUtils;
import net.icejz.framework.common.utils.IpUtils;
import net.icejz.framework.security.cache.TokenStoreCache;
import net.icejz.framework.security.crypto.Sm2Util;
import net.icejz.framework.security.mobile.MobileAuthenticationToken;
import net.icejz.framework.security.third.ThirdAuthenticationToken;
import net.icejz.framework.security.third.ThirdLogin;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.cache.SmsSendCache;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.enums.LoginOperationEnum;
import net.icejz.system.enums.SysParamsEnum;
import net.icejz.system.service.*;
import net.icejz.system.vo.*;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 权限认证服务
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysAuthServiceImpl implements SysAuthService {
    private final SysCaptchaService sysCaptchaService;
    private final TokenStoreCache tokenStoreCache;
    private final AuthenticationManager authenticationManager;
    private final SysLogLoginService sysLogLoginService;
    private final SysUserService sysUserService;
    private final SysUserDao sysUserDao;
    private final SysUserTokenService sysUserTokenService;
    private final SmsApi smsApi;
    private final SmsSendCache smsSendCache;
    private final SysParamsService sysParamsService;

    @Override
    public SysUserTokenVO loginByAccount(SysAccountLoginVO login) {
        boolean flag = sysCaptchaService.validate(login.getKey(), login.getCaptcha());
        if (!flag) {
            sysLogLoginService.save(login.getUsername(), Constant.FAIL, LoginOperationEnum.CAPTCHA_FAIL.getValue());
            throw new ServerException("验证码错误");
        }

        String password;
        try {
            password = Sm2Util.decrypt(login.getPassword());
        } catch (Exception e) {
            throw new ServerException("密码解密失败，请刷新页面后重试");
        }

        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(login.getUsername(), password));
        } catch (DisabledException e) {
            sysLogLoginService.save(login.getUsername(), Constant.FAIL, LoginOperationEnum.ACCOUNT_FAIL.getValue());
            throw new ServerException(banTipByUsername(login.getUsername()));
        } catch (BadCredentialsException e) {
            throw new ServerException("用户名或密码错误");
        }

        UserDetail user = (UserDetail) authentication.getPrincipal();
        return issueToken(user);
    }

    @Override
    public SysUserTokenVO loginByMobile(SysMobileLoginVO login) {
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new MobileAuthenticationToken(login.getMobile(), login.getCode()));
        } catch (DisabledException e) {
            throw new ServerException(banTipByMobile(login.getMobile()));
        } catch (BadCredentialsException e) {
            throw new ServerException("手机号或验证码错误");
        }

        UserDetail user = (UserDetail) authentication.getPrincipal();
        return issueToken(user);
    }

    @Override
    public SysUserTokenVO loginByThird(SysThirdCallbackVO login) {
        Authentication authentication;
        try {
            ThirdLogin thirdLogin = BeanUtil.copyProperties(login, ThirdLogin.class);
            authentication = authenticationManager.authenticate(new ThirdAuthenticationToken(thirdLogin));
        } catch (DisabledException e) {
            throw new ServerException("抱歉，您的账号已被封禁，暂时无法登录。如有疑问，请联系系统管理员。");
        } catch (BadCredentialsException e) {
            throw new ServerException("第三方登录失败");
        }

        UserDetail user = (UserDetail) authentication.getPrincipal();
        return issueToken(user);
    }

    private String banTipByUsername(String username) {
        if (StrUtil.isBlank(username)) {
            return sysUserService.getLoginBanTip(null);
        }
        return sysUserService.getLoginBanTip(sysUserDao.getByUsername(username.trim()));
    }

    private String banTipByMobile(String mobile) {
        if (StrUtil.isBlank(mobile)) {
            return sysUserService.getLoginBanTip(null);
        }
        return sysUserService.getLoginBanTip(sysUserDao.getByMobile(mobile.trim()));
    }

    private SysUserTokenVO issueToken(UserDetail user) {
        fillSessionMeta(user);
        SysUserTokenVO userTokenVO = sysUserTokenService.createToken(user.getId());
        tokenStoreCache.saveUser(userTokenVO.getAccessToken(), user);
        return userTokenVO;
    }

    private void fillSessionMeta(UserDetail user) {
        user.setLoginTime(LocalDateTime.now());
        HttpServletRequest request = HttpContextUtils.getHttpServletRequest();
        if (request == null) {
            user.setClientType("pc");
            return;
        }
        user.setLoginIp(IpUtils.getIpAddr(request));
        String userAgent = request.getHeader(HttpHeaders.USER_AGENT);
        user.setUserAgent(userAgent);
        String header = request.getHeader("X-Client-Type");
        if (StrUtil.isNotBlank(header)) {
            user.setClientType(header.trim().toLowerCase());
            return;
        }
        if (StrUtil.isBlank(userAgent)) {
            user.setClientType("pc");
            return;
        }
        String ua = userAgent.toLowerCase();
        if (ua.contains("micromessenger")) {
            user.setClientType("mp");
        } else if (ua.contains("uni-app") || ua.contains("miniprogram") || ua.contains("android")
                || ua.contains("iphone") || ua.contains("ipad") || ua.contains("mobile")) {
            user.setClientType("app");
        } else {
            user.setClientType("pc");
        }
    }

    @Override
    public boolean sendCode(SysSendCodeVO send) {
        boolean captchaOk = sysCaptchaService.validateRequired(send.getKey(), send.getCaptcha());
        if (!captchaOk) {
            throw new ServerException("验证码错误");
        }

        String mobile = send.getMobile();
        int interval = parseIntParam(SysParamsEnum.SMS_CODE_INTERVAL_SECONDS.name(), 60);
        int hourLimit = parseIntParam(SysParamsEnum.SMS_CODE_HOUR_LIMIT.name(), 10);
        smsSendCache.checkSendLimit(mobile, interval, hourLimit);

        String code = RandomUtil.randomNumbers(6);

        SysUserVO user = sysUserService.getByMobile(mobile);
        if (user == null) {
            throw new ServerException("手机号未注册");
        }

        boolean ok = smsApi.sendCode(mobile, "code", code);
        if (ok) {
            smsSendCache.markSent(mobile, interval);
        }
        return ok;
    }

    private int parseIntParam(String key, int defaultValue) {
        try {
            String value = sysParamsService.getString(key);
            if (StrUtil.isBlank(value)) {
                return defaultValue;
            }
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }

    @Override
    public AccessTokenVO getAccessToken(String refreshToken) {
        SysUserTokenVO token = sysUserTokenService.refreshToken(refreshToken);

        AccessTokenVO accessToken = new AccessTokenVO();
        accessToken.setAccessToken(token.getAccessToken());
        accessToken.setAccessTokenExpire(token.getAccessTokenExpire());

        return accessToken;
    }

    @Override
    public void logout(String accessToken) {
        UserDetail user = tokenStoreCache.getUser(accessToken);
        if (user == null) {
            sysUserTokenService.expireByAccessToken(accessToken);
            return;
        }

        sysUserTokenService.expireByAccessToken(accessToken);
        sysLogLoginService.save(user.getUsername(), Constant.SUCCESS, LoginOperationEnum.LOGOUT_SUCCESS.getValue());
    }
}
