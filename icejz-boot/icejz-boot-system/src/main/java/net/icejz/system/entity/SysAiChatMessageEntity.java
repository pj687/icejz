package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * AI 对话消息
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_ai_chat_message")
public class SysAiChatMessageEntity extends BaseEntity {
    private Long sessionId;
    private Long userId;
    private String role;
    private String content;
}
