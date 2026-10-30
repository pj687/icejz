package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Schema(description = "AI对话会话")
public class SysAiChatSessionVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "id")
    private Long id;

    @Schema(description = "标题")
    private String title;

    @Schema(description = "最后消息时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime lastMsgTime;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;
}
