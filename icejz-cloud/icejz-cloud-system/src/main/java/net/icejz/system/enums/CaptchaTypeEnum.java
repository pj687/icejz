package net.icejz.system.enums;

import cn.hutool.core.util.StrUtil;
import lombok.Getter;

/**
 * 登录验证码类型（系统参数 LOGIN_CAPTCHA_TYPE）
 */
@Getter
public enum CaptchaTypeEnum {
    SPEC("spec", "input", "请输入验证码"),
    NUMBER("number", "input", "请输入数字验证码"),
    CHINESE("chinese", "input", "请输入汉字验证码"),
    ARITHMETIC("arithmetic", "input", "请输入计算结果"),
    PATTERN("pattern", "click", "请点击图中指定图案"),
    /** 滑动拼图（AJ-Captcha 同类交互） */
    BLOCK_PUZZLE("block_puzzle", "slider", "请拖动滑块完成拼图"),
    /** 文字点选（AJ-Captcha 同类交互） */
    CLICK_WORD("click_word", "word", "请依次点击图中文字"),
    /** 浏览器工作量证明（无感算力校验） */
    POW("pow", "pow", "正在进行安全校验…"),
    /** Cloudflare Turnstile（需配置站点密钥） */
    TURNSTILE("turnstile", "turnstile", "请完成人机验证");

    private final String code;
    private final String mode;
    private final String tip;

    CaptchaTypeEnum(String code, String mode, String tip) {
        this.code = code;
        this.mode = mode;
        this.tip = tip;
    }

    public static CaptchaTypeEnum of(String code) {
        if (StrUtil.isBlank(code)) {
            return SPEC;
        }
        for (CaptchaTypeEnum item : values()) {
            if (item.code.equalsIgnoreCase(code.trim())) {
                return item;
            }
        }
        return SPEC;
    }

    public boolean isBehavior() {
        return this == BLOCK_PUZZLE || this == CLICK_WORD || this == POW || this == TURNSTILE;
    }
}
