package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

import java.time.LocalDateTime;

/**
 * 站内消息
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_message")
public class SysMessageEntity extends BaseEntity {
    /**
     * 标题
     */
    private String title;
    /**
     * 内容
     */
    private String content;
    /**
     * 类型 0：通知 1：公告 2：私信
     */
    private Integer type;
    /**
     * 接收范围 0：全部用户 1：指定用户
     */
    private Integer receiverType;
    /**
     * 发送人ID
     */
    private Long senderId;
    /**
     * 发送人姓名
     */
    private String senderName;
    /**
     * 状态 0：草稿 1：已发送
     */
    private Integer status;
    /**
     * 发送时间
     */
    private LocalDateTime sendTime;
    /**
     * 租户ID
     */
    private Long tenantId;
}
