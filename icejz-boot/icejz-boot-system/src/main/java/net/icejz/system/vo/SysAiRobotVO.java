package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "AI机器人形象设置")
public class SysAiRobotVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "机器人名称")
    private String name;

    @Schema(description = "欢迎语")
    private String welcome;

    @Schema(description = "是否启用 0/1")
    private Integer enabled;

    @Schema(description = "默认模型ID")
    private Long defaultModelId;
}
