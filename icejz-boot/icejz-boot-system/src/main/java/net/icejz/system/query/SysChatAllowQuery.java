package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "聊天白名单查询")
public class SysChatAllowQuery extends Query {
    private Integer type;
    private Integer status;
}
