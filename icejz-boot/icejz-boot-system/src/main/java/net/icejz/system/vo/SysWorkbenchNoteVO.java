package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Schema(description = "工作台日历记事")
public class SysWorkbenchNoteVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "id")
    private Long id;

    @Schema(description = "日期 yyyy-MM-dd")
    @NotBlank(message = "日期不能为空")
    private String noteDate;

    @Schema(description = "类型 memo/nudge/remind")
    @NotBlank(message = "类型不能为空")
    private String noteType;

    @Schema(description = "内容")
    @NotBlank(message = "内容不能为空")
    private String content;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;
}
