package net.icejz.framework.security.mobile;

/**
 * 手机短信登录，验证码效验
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface MobileVerifyCodeService {

    boolean verifyCode(String mobile, String code);
}
