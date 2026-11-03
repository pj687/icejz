package net.icejz.system.service;

import net.icejz.system.vo.SysCaptchaVO;

/**
 * 验证码
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SysCaptchaService {
    /**
     * 生成验证码（默认 PC 通道）
     */
    default SysCaptchaVO generate() {
        return generate("pc");
    }

    /**
     * 按通道生成验证码
     *
     * @param channel pc / app / sms
     */
    SysCaptchaVO generate(String channel);

    /**
     * 验证码效验
     *
     * @param key  key
     * @param code 验证码
     * @return true：成功  false：失败
     */
    boolean validate(String key, String code);

    /**
     * 强制校验图形验证码（不受登录验证码开关影响，用于发短信防刷）
     *
     * @param key  key
     * @param code 验证码
     * @return true：成功  false：失败
     */
    boolean validateRequired(String key, String code);

    /**
     * 是否开启登录验证码
     *
     * @return true：开启  false：关闭
     */
    boolean isCaptchaEnabled();
}
