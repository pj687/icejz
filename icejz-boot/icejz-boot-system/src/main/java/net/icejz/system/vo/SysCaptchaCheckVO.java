package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 验证码预校验请求
 */
@Data
@Schema(description = "验证码预校验")
public class SysCaptchaCheckVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "验证码 key")
    private String key;

    @Schema(description = "用户提交的验证值")
    private String captcha;
}
