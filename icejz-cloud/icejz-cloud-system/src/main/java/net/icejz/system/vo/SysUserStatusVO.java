package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serializable;

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
}
