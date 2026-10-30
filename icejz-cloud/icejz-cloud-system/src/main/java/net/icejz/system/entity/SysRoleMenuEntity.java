package net.icejz.system.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.mybatis.entity.BaseEntity;

/**
 * 角色菜单关系
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper=false)
@TableName("sys_role_menu")
public class SysRoleMenuEntity extends BaseEntity {
	/**
	 * 角色ID
	 */
	private Long roleId;
	/**
	 * 菜单ID
	 */
	private Long menuId;

}
