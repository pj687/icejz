package net.icejz.system.query;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import net.icejz.framework.common.query.Query;

/**
 * 附件管理查询
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "附件管理查询")
public class SysAttachmentQuery extends Query {
    @Schema(description = "附件名称")
    private String name;

    @Schema(description = "存储平台")
    private String platform;

}