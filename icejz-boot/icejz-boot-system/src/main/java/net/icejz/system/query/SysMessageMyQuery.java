package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

/**
 * 我的站内消息查询
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "我的站内消息查询")
public class SysMessageMyQuery extends Query {
    @Schema(description = "标题")
    private String title;

    @Schema(description = "阅读状态 0：未读 1：已读")
    private Integer readStatus;
}
