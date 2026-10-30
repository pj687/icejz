package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

/**
 * 字典数据
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "字典数据查询")
public class SysDictDataQuery extends Query {
    @Schema(description = "字典类型ID", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "字典类型ID不能为空")
    private Long dictTypeId;

}
