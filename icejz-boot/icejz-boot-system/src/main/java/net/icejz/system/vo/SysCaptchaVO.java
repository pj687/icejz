package net.icejz.system.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 图片 / 行为验证码
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
@Schema(description = "验证码")
public class SysCaptchaVO implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "key")
    private String key;

    @Schema(description = "主图 base64（字符码 / 点选底图 / 拼图底图）")
    private String image;

    @Schema(description = "类型")
    private String type;

    @Schema(description = "交互模式：input/click/slider/word/pow/turnstile")
    private String mode;

    @Schema(description = "提示文案")
    private String tip;

    @Schema(description = "是否开启验证码")
    private Boolean enabled;

    @Schema(description = "滑块拼图：缺口块图片")
    private String jigsawImage;

    @Schema(description = "滑块拼图：缺口纵向位置")
    private Integer jigsawY;

    @Schema(description = "滑块拼图：底图像素宽")
    private Integer puzzleWidth;

    @Schema(description = "滑块拼图：底图像素高")
    private Integer puzzleHeight;

    @Schema(description = "滑块拼图：滑块图像素宽（含凸起）")
    private Integer jigsawWidth;

    @Schema(description = "滑块拼图：拼图块主体边长（不含凸起）")
    private Integer pieceSize;

    @Schema(description = "文字点选：需要点击的文字列表")
    private List<String> words;

    @Schema(description = "PoW：挑战串")
    private String challenge;

    @Schema(description = "PoW：难度（前导 0 个数）")
    private Integer difficulty;

    @Schema(description = "Turnstile：站点公钥")
    private String siteKey;
}
