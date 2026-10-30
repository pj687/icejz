package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 分配角色查询
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "分配角色查询")
public class SysRoleUserQuery extends SysUserQuery {
    @Schema(description = "角色ID")
    private Long roleId;

}
