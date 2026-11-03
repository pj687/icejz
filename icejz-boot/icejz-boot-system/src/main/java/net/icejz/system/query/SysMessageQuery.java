package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

/**
 * 站内消息查询
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "站内消息查询")
public class SysMessageQuery extends Query {
    @Schema(description = "标题")
    private String title;

    @Schema(description = "类型 0：通知 1：公告 2：私信")
    private Integer type;

    @Schema(description = "状态 0：草稿 1：已发送")
    private Integer status;
}
