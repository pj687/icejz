package net.icejz.system.enums;

import cn.hutool.core.util.StrUtil;
import lombok.Getter;

/**
 * 登录验证码使用端
 */
@Getter
public enum CaptchaChannelEnum {
    /** PC 管理端账号密码登录 */
    PC("pc", "PC管理端-账号登录"),
    /** App / 小程序 / H5 移动端登录 */
    APP("app", "移动端登录"),
    /** 短信发送前图形验证码（PC 手机登录 / App 发短信） */
    SMS("sms", "短信发送图形码");

    private final String code;
    private final String label;

    CaptchaChannelEnum(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public static CaptchaChannelEnum of(String code) {
        if (StrUtil.isBlank(code)) {
            return PC;
        }
        String value = code.trim();
        // 兼容旧调用：mobile -> sms
        if ("mobile".equalsIgnoreCase(value)) {
            return SMS;
        }
        for (CaptchaChannelEnum item : values()) {
            if (item.code.equalsIgnoreCase(value)) {
                return item;
            }
        }
        return PC;
    }
}
