package net.icejz.system.service;

import net.icejz.system.vo.SysLoginSecurityConfigVO;

/**
 * 登录安全配置
 */
public interface SysLoginSecurityConfigService {

    SysLoginSecurityConfigVO getConfig();

    void saveConfig(SysLoginSecurityConfigVO vo);
}
