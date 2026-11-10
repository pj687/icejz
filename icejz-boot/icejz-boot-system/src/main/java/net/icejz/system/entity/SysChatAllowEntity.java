package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 聊天白名单例外
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_chat_allow")
public class SysChatAllowEntity extends BaseEntity {
    /** 1用户-用户 2机构-机构 3用户-机构 */
    private Integer type;
    private Long srcId;
    private Long dstId;
    /** 1启用 0停用 */
    private Integer status;
    private String remark;
}
