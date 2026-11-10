package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.time.LocalDateTime;

/**
 * 聊天会话
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_chat_conversation")
public class SysChatConversationEntity extends BaseEntity {
    /** 1单聊 2群聊 */
    private Integer type;
    private String title;
    private String avatar;
    private Long ownerId;
    /** 单聊唯一键 minId_maxId */
    private String directKey;
    private Long lastMsgId;
    private String lastMsgContent;
    private LocalDateTime lastMsgTime;
    private Integer lastMsgType;
    /** 1正常 0解散 */
    private Integer status;
    private Long tenantId;
}
