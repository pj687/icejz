package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 角色聊天自定义机构
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_chat_scope_org")
public class SysChatScopeOrgEntity extends BaseEntity {
    private Long roleId;
    private Long orgId;
}
