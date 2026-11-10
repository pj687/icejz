package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 聊天消息
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_chat_message")
public class SysChatMessageEntity extends BaseEntity {
    private Long conversationId;
    private Long senderId;
    private String senderName;
    /** 0文本 1图片 2文件 9系统 */
    private Integer msgType;
    private String content;
    private String fileUrl;
    private String fileName;
    private Long fileSize;
    /** 1正常 0撤回 */
    private Integer status;
}
