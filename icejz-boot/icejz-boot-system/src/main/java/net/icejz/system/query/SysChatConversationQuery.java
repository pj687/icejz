package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "会话列表查询")
public class SysChatConversationQuery extends Query {
    @Schema(description = "关键词")
    private String keyword;
}
