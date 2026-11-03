package net.icejz.system.service;

import net.icejz.system.vo.SysCaptchaConfigVO;

/**
 * 分端验证码配置
 */
public interface SysCaptchaConfigService {

    SysCaptchaConfigVO getConfig();

    void saveConfig(SysCaptchaConfigVO vo);
}
