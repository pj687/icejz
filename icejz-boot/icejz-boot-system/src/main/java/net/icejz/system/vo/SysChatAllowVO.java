package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.time.LocalDateTime;

@Data
@Schema(description = "聊天白名单")
public class SysChatAllowVO {
    private Long id;
    @NotNull(message = "类型不能为空")
    @Schema(description = "1用户-用户 2机构-机构 3用户-机构")
    private Integer type;
    @NotNull(message = "源ID不能为空")
    private Long srcId;
    @NotNull(message = "目标ID不能为空")
    private Long dstId;
    private Integer status;
    private String remark;
    private String srcName;
    private String dstName;
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;
}
