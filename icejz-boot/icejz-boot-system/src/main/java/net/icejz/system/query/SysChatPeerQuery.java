package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

import java.util.List;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "聊天可选人查询")
public class SysChatPeerQuery extends Query {
    private String username;
    private String mobile;
    private String realName;
    @Schema(description = "机构ID列表")
    private List<Long> orgId;
}
