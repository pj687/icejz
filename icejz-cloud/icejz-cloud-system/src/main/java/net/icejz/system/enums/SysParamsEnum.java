package net.icejz.system.enums;

/**
 * 系统参数 枚举
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public enum SysParamsEnum {
    /**
     * 登录验证码开关（账号登录是否启用图形验证码）
     */
    LOGIN_CAPTCHA,
    /**
     * 登录验证码类型（兼容旧配置，优先使用分通道参数）
     */
    LOGIN_CAPTCHA_TYPE,
    /**
     * PC 管理端登录验证码类型
     */
    LOGIN_CAPTCHA_TYPE_PC,
    /**
     * 移动端 / APP 登录验证码类型
     */
    LOGIN_CAPTCHA_TYPE_APP,
    /**
     * 短信发送前图形验证码类型
     */
    LOGIN_CAPTCHA_TYPE_SMS,
    /**
     * Cloudflare Turnstile 站点公钥
     */
    TURNSTILE_SITE_KEY,
    /**
     * Cloudflare Turnstile 密钥
     */
    TURNSTILE_SECRET_KEY,
    /**
     * PoW 难度（前导0个数，建议 2~4）
     */
    CAPTCHA_POW_DIFFICULTY,
    /**
     * 同一手机号发送短信最小间隔秒数
     */
    SMS_CODE_INTERVAL_SECONDS,
    /**
     * 同一手机号每小时最大发送次数
     */
    SMS_CODE_HOUR_LIMIT,
    /**
     * 是否允许多设备同时登录（true：多设备；false：单设备互踢）
     */
    MULTI_DEVICE_LOGIN,
    /**
     * 多设备登录数量上限（仅 MULTI_DEVICE_LOGIN=true 时生效）
     */
    MULTI_DEVICE_MAX
}
