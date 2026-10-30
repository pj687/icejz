package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "AI对话结果")
public class SysAiChatResultVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "回复内容")
    private String content;

    @Schema(description = "模型ID")
    private Long modelId;

    @Schema(description = "模型名称")
    private String modelName;

    @Schema(description = "会话ID")
    private Long sessionId;
}
