package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 工作台日历记事
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_workbench_note")
public class SysWorkbenchNoteEntity extends BaseEntity {
    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 日期 yyyy-MM-dd
     */
    private String noteDate;

    /**
     * 类型 memo / nudge / remind
     */
    private String noteType;

    /**
     * 内容
     */
    private String content;
}
