package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;
import org.hibernate.validator.constraints.Range;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 站内消息
 */
@Data
@Schema(description = "站内消息")
public class SysMessageVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "id")
    private Long id;

    @Schema(description = "标题", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "标题不能为空")
    private String title;

    @Schema(description = "内容", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "内容不能为空")
    private String content;

    @Schema(description = "类型 0：通知 1：公告 2：私信", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "类型不能为空")
    @Range(min = 0, max = 2, message = "类型不正确")
    private Integer type;

    @Schema(description = "接收范围 0：全部用户 1：指定用户", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "接收范围不能为空")
    @Range(min = 0, max = 1, message = "接收范围不正确")
    private Integer receiverType;

    @Schema(description = "指定接收人ID列表")
    private List<Long> receiverIdList;

    @Schema(description = "发送人ID")
    private Long senderId;

    @Schema(description = "发送人姓名")
    private String senderName;

    @Schema(description = "状态 0：草稿 1：已发送")
    private Integer status;

    @Schema(description = "发送时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime sendTime;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime createTime;

    @Schema(description = "接收人数")
    private Integer receiverCount;

    @Schema(description = "已读人数")
    private Integer readCount;
}
