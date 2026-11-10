package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.time.LocalDateTime;

/**
 * 聊天成员
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_chat_member")
public class SysChatMemberEntity extends BaseEntity {
    private Long conversationId;
    private Long userId;
    /** 0成员 1管理员 2群主 */
    private Integer role;
    /** 0否 1免打扰 */
    private Integer mute;
    private Long lastReadMsgId;
    private LocalDateTime joinTime;
}
