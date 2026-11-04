package net.icejz.system.enums;

/**
 * 系统参数 枚举
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public enum SysParamsEnum {
    /**
     * @deprecated 已迁至表 sys_captcha_config.enabled，保留枚举仅兼容旧数据
     */
    LOGIN_CAPTCHA,
    /**
     * @deprecated 已迁至表 sys_captcha_config，保留枚举仅兼容旧数据
     */
    LOGIN_CAPTCHA_TYPE,
    /**
     * @deprecated 已迁至表 sys_captcha_config.pc_type
     */
    LOGIN_CAPTCHA_TYPE_PC,
    /**
     * @deprecated 已迁至表 sys_captcha_config.app_type
     */
    LOGIN_CAPTCHA_TYPE_APP,
    /**
     * @deprecated 已迁至表 sys_captcha_config.sms_type
     */
    LOGIN_CAPTCHA_TYPE_SMS,
    /**
     * @deprecated 已迁至表 sys_captcha_config.turnstile_site_key
     */
    TURNSTILE_SITE_KEY,
    /**
     * @deprecated 已迁至表 sys_captcha_config.turnstile_secret_key
     */
    TURNSTILE_SECRET_KEY,
    /**
     * @deprecated 已迁至表 sys_captcha_config.pow_difficulty
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
     * 是否允许多设备同时登录（true：可多设备，个人仍可覆盖关闭；false：全员强制单设备互踢，个人不可开启）
     */
    MULTI_DEVICE_LOGIN,
    /**
     * 多设备登录数量上限（仅 MULTI_DEVICE_LOGIN=true 时生效）
     */
    MULTI_DEVICE_MAX
}
