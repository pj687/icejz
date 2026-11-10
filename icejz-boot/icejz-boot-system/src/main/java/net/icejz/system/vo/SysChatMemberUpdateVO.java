package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "会话成员变更")
public class SysChatMemberUpdateVO {
    @NotNull
    private Long conversationId;
    @NotEmpty
    private List<Long> userIds;
    @Schema(description = "成员角色，加人时可选 0成员 1管理员")
    private Integer role;
}
