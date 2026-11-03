package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 登录安全配置
 */
@Data
@Schema(description = "登录安全配置")
public class SysLoginSecurityConfigVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "是否允许多设备同时登录")
    private Boolean multiDeviceLogin;

    @Schema(description = "多设备登录数量上限")
    private Integer multiDeviceMax;
}
