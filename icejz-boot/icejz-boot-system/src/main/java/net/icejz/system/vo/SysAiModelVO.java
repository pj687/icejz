package net.icejz.system.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@Schema(description = "AI模型配置")
public class SysAiModelVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "id")
    private Long id;

    @Schema(description = "显示名称")
    private String name;

    @Schema(description = "厂商")
    private String provider;

    @Schema(description = "接入类型 0本地 1线上")
    private Integer apiType;

    @Schema(description = "接口地址")
    private String baseUrl;

    @Schema(description = "API Key")
    private String apiKey;

    @Schema(description = "模型名")
    private String modelName;

    @Schema(description = "温度")
    private BigDecimal temperature;

    @Schema(description = "最大token")
    private Integer maxTokens;

    @Schema(description = "系统提示词")
    private String systemPrompt;

    @Schema(description = "是否默认")
    private Integer isDefault;

    @Schema(description = "排序")
    private Integer sort;

    @Schema(description = "状态")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "版本号")
    private Integer version;

    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private Date createTime;

    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private Date updateTime;
}
