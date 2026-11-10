package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.time.LocalDateTime;

@Data
@Schema(description = "聊天消息")
public class SysChatMessageVO {
    private Long id;
    @NotNull(message = "会话不能为空")
    private Long conversationId;
    private Long senderId;
    private String senderName;
    private String senderAvatar;
    @Schema(description = "0文本 1图片 2文件 9系统")
    @NotNull(message = "消息类型不能为空")
    private Integer msgType;
    private String content;
    private String fileUrl;
    private String fileName;
    private Long fileSize;
    @Schema(description = "1正常 0撤回")
    private Integer status;
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;
    private Boolean mine;
}
