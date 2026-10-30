package net.icejz.framework.mybatis.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import net.icejz.framework.common.trans.TransPojo;

import java.time.LocalDateTime;

/**
 * Entity基类
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public abstract class BaseEntity implements TransPojo {
    /**
     * id
     */
    @TableId
    private Long id;

    /**
     * 创建者
     */
    @TableField(fill = FieldFill.INSERT)
    private Long creator;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新者
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updater;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 版本号
     */
    @Version
    @TableField(fill = FieldFill.INSERT)
    private Integer version;

    /**
     * 删除标记
     */
    @TableLogic
    @TableField(fill = FieldFill.INSERT)
    private Integer deleted;
}
