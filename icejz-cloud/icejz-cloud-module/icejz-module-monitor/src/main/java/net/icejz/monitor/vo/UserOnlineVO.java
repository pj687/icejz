package net.icejz.monitor.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import net.icejz.framework.common.utils.DateUtils;

import java.time.LocalDateTime;

/**
 * 在线用户
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@Schema(description = "在线用户")
public class UserOnlineVO {
    @Schema(description = "id")
    private Long id;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "姓名")
    private String realName;

    @Schema(description = "性别")
    private Integer gender;

    @Schema(description = "邮箱")
    private String email;

    @Schema(description = "accessToken")
    private String accessToken;

    @Schema(description = "登录IP")
    private String loginIp;

    @Schema(description = "User-Agent")
    private String userAgent;

    @Schema(description = "客户端类型")
    private String clientType;

    @Schema(description = "登录时间")
    @JsonFormat(pattern = DateUtils.DATE_TIME_PATTERN)
    private LocalDateTime loginTime;
}
