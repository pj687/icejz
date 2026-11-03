package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 当前用户登录安全（个人多设备设置）
 */
@Data
@Schema(description = "个人登录安全设置")
public class SysUserLoginSecurityVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "系统默认是否允许多设备")
    private Boolean systemMultiDeviceLogin;

    @Schema(description = "系统默认多设备上限")
    private Integer systemMultiDeviceMax;

    @Schema(description = "个人设置：null跟随系统 0单设备 1多设备")
    private Integer multiDeviceLogin;

    @Schema(description = "个人多设备上限：null跟随系统")
    private Integer multiDeviceMax;

    @Schema(description = "当前生效是否多设备")
    private Boolean effectiveMultiDeviceLogin;

    @Schema(description = "当前生效设备上限")
    private Integer effectiveMultiDeviceMax;
}
