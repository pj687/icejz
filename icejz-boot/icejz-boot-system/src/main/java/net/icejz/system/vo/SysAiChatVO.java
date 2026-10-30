package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
@Schema(description = "AI对话请求")
public class SysAiChatVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "用户消息")
    private String message;

    @Schema(description = "指定模型ID，为空则用默认")
    private Long modelId;

    @Schema(description = "会话ID，为空则自动新建并落库")
    private Long sessionId;

    @Schema(description = "历史消息")
    private List<ChatMessage> history;

    @Data
    public static class ChatMessage implements Serializable {
        private String role;
        private String content;
    }
}
