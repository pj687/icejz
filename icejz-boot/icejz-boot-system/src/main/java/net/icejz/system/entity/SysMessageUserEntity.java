package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.time.LocalDateTime;

/**
 * 站内消息接收
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_message_user")
public class SysMessageUserEntity extends BaseEntity {
    /**
     * 消息ID
     */
    private Long messageId;
    /**
     * 接收人ID
     */
    private Long receiverId;
    /**
     * 接收人姓名
     */
    private String receiverName;
    /**
     * 阅读状态 0：未读 1：已读
     */
    private Integer readStatus;
    /**
     * 阅读时间
     */
    private LocalDateTime readTime;
}
