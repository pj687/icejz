package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 发送短信验证码
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@Schema(description = "发送短信验证码")
public class SysSendCodeVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "手机号")
    private String mobile;

    @Schema(description = "图形验证码唯一key")
    private String key;

    @Schema(description = "图形验证码")
    private String captcha;
}
