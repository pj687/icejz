package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 附件管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_attachment")
public class SysAttachmentEntity extends BaseEntity {
    /**
     * 附件名称
     */
    private String name;

    /**
     * 附件地址
     */
    private String url;

    /**
     * 附件大小
     */
    private Long size;

    /**
     * 存储平台
     */
    private String platform;
    /**
     * 租户ID
     */
    private Long tenantId;

}