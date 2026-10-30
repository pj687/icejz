package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "AI模型查询")
public class SysAiModelQuery extends Query {
    @Schema(description = "名称")
    private String name;

    @Schema(description = "接入类型")
    private Integer apiType;

    @Schema(description = "状态")
    private Integer status;
}
