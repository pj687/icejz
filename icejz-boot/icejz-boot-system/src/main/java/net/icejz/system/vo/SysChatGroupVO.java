package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "创建群聊")
public class SysChatGroupVO {
    @NotBlank(message = "群名称不能为空")
    private String title;
    private String avatar;
    @NotEmpty(message = "请选择群成员")
    private List<Long> memberIds;
}
