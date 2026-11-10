package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "聊天可选人")
public class SysChatPeerVO {
    private Long id;
    private String username;
    private String realName;
    private String mobile;
    private String avatar;
    private Long orgId;
    private String orgName;
}
