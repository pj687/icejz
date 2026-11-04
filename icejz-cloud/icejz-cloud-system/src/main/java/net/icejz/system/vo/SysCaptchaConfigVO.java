package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 分端验证码配置
 */
@Data
@Schema(description = "分端验证码配置")
public class SysCaptchaConfigVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "账号密码登录是否开启验证码")
    private Boolean enabled;

    @Schema(description = "PC管理端账号登录验证码类型")
    private String pcType;

    @Schema(description = "短信发送前图形验证码类型（PC手机登录/App发短信）")
    private String smsType;

    /** @deprecated 兼容字段，等同 smsType */
    @Schema(description = "兼容旧字段，等同 smsType")
    private String mobileType;

    @Schema(description = "移动端登录验证码类型")
    private String appType;

    @Schema(description = "Turnstile 站点公钥")
    private String turnstileSiteKey;

    @Schema(description = "Turnstile 密钥")
    private String turnstileSecretKey;

    @Schema(description = "PoW 难度")
    private Integer powDifficulty;

    @Schema(description = "可选验证码类型列表")
    private List<CaptchaTypeOption> typeOptions = new ArrayList<>();

    @Data
    @Schema(description = "验证码类型选项")
    public static class CaptchaTypeOption implements Serializable {
        private static final long serialVersionUID = 1L;
        private String code;
        private String mode;
        private String tip;
        private String label;

        public CaptchaTypeOption() {
        }

        public CaptchaTypeOption(String code, String mode, String tip, String label) {
            this.code = code;
            this.mode = mode;
            this.tip = tip;
            this.label = label;
        }
    }
}
