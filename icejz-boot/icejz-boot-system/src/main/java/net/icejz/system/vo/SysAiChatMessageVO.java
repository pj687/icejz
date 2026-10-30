package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Schema(description = "AI对话消息")
public class SysAiChatMessageVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "id")
    private Long id;

    @Schema(description = "会话ID")
    private Long sessionId;

    @Schema(description = "角色 user/assistant")
    private String role;

    @Schema(description = "内容")
    private String content;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;
}
