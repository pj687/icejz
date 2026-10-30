package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "平台版本信息")
public class SysAppVersionVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "平台名称")
    private String name;

    @Schema(description = "版本号")
    private String version;

    @Schema(description = "应用名")
    private String application;
}
