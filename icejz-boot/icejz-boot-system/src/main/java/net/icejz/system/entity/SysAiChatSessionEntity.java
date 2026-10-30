package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.time.LocalDateTime;

/**
 * AI 对话会话
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_ai_chat_session")
public class SysAiChatSessionEntity extends BaseEntity {
    private Long userId;
    private String title;
    private LocalDateTime lastMsgTime;
}
