package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "消息历史查询")
public class SysChatMessageQuery extends Query {
    @NotNull(message = "会话不能为空")
    private Long conversationId;
    @Schema(description = "拉取此ID之前的消息（向上翻页）")
    private Long beforeId;
}
