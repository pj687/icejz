package net.icejz.system.service;

import net.icejz.system.enums.CaptchaChannelEnum;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.vo.SysCaptchaConfigVO;

/**
 * 分端验证码配置（独立表）
 */
public interface SysCaptchaConfigService {

    SysCaptchaConfigVO getConfig();

    void saveConfig(SysCaptchaConfigVO vo);

    /** 账号密码登录是否开启验证码 */
    boolean isEnabled();

    /** 按通道解析验证码类型 */
    CaptchaTypeEnum resolveType(CaptchaChannelEnum channel);

    String getTurnstileSiteKey();

    String getTurnstileSecretKey();

    int getPowDifficulty();
}
