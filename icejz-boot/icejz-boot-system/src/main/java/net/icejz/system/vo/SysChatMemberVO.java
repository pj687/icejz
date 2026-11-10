package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.time.LocalDateTime;

@Data
@Schema(description = "聊天成员")
public class SysChatMemberVO {
    private Long id;
    private Long conversationId;
    private Long userId;
    private String realName;
    private String username;
    private String avatar;
    @Schema(description = "0成员 1管理员 2群主")
    private Integer role;
    private Integer mute;
    private Long lastReadMsgId;
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime joinTime;
}
