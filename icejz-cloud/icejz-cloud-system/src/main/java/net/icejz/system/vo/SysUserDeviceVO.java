package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 登录设备 / 在线会话
 */
@Data
@Schema(description = "登录设备")
public class SysUserDeviceVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "accessToken")
    private String accessToken;

    @Schema(description = "登录IP")
    private String loginIp;

    @Schema(description = "User-Agent")
    private String userAgent;

    @Schema(description = "客户端类型")
    private String clientType;

    @Schema(description = "登录时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime loginTime;

    @Schema(description = "是否当前设备")
    private Boolean current;
}
