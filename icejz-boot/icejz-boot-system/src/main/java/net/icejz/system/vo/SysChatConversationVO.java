package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "聊天会话")
public class SysChatConversationVO {
    private Long id;
    @Schema(description = "1单聊 2群聊")
    private Integer type;
    private String title;
    private String avatar;
    private Long ownerId;
    private Long lastMsgId;
    private String lastMsgContent;
    private Integer lastMsgType;
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime lastMsgTime;
    private Integer status;
    @Schema(description = "未读数")
    private Long unreadCount;
    @Schema(description = "展示名称（单聊对方姓名/群名）")
    private String displayName;
    @Schema(description = "展示头像")
    private String displayAvatar;
    @Schema(description = "对方用户ID（仅单聊）")
    private Long peerUserId;
    @Schema(description = "成员数")
    private Integer memberCount;
    private List<SysChatMemberVO> members;
}
