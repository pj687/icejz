package net.icejz.system.service;

import net.icejz.system.vo.*;

/**
 * 权限认证服务
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysAuthService {

    /**
     * 账号密码登录
     *
     * @param login 登录信息
     */
    SysUserTokenVO loginByAccount(SysAccountLoginVO login);

    /**
     * 手机短信登录
     *
     * @param login 登录信息
     */
    SysUserTokenVO loginByMobile(SysMobileLoginVO login);

    /**
     * 第三方登录
     *
     * @param login 登录信息
     */
    SysUserTokenVO loginByThird(SysThirdCallbackVO login);

    /**
     * 发送手机验证码（需先通过图形验证码）
     *
     * @param send 手机号与图形验证码
     */
    boolean sendCode(SysSendCodeVO send);

    /**
     * 根据刷新Token，获取AccessToken
     *
     * @param refreshToken refreshToken
     */
    AccessTokenVO getAccessToken(String refreshToken);

    /**
     * 退出登录
     *
     * @param accessToken accessToken
     */
    void logout(String accessToken);
}
