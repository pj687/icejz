package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "发起单聊")
public class SysChatDirectVO {
    @NotNull(message = "对方用户不能为空")
    private Long userId;
}
