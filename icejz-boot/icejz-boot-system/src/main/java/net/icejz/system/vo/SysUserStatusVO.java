package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户状态变更（封禁 / 解封）
 */
@Data
@Schema(description = "用户状态变更")
public class SysUserStatusVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @NotNull(message = "用户ID不能为空")
    @Schema(description = "用户ID")
    private Long id;

    @NotNull(message = "状态不能为空")
    @Schema(description = "状态 0：封禁 1：正常")
    private Integer status;

    @Schema(description = "封禁原因（可选）")
    private String reason;

    /**
     * permanent | 5m | 10m | 15m | 30m | 1h | 6h | 12h | 1d | 3d | 7d | 15d | 30d | 90d | custom
     */
    @Schema(description = "封禁时长类型：permanent/5m/10m/15m/30m/1h/6h/12h/1d/3d/7d/15d/30d/90d/custom")
    private String banDuration;

    @Schema(description = "自定义封禁到期时间（banDuration=custom 时必填）")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime banExpireTime;

    @Schema(description = "是否发送站内封禁/解封通知")
    private Boolean sendNotify;
}
