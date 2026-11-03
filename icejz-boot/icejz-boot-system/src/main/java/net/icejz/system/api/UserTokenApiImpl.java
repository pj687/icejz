package net.icejz.system.api;

import lombok.AllArgsConstructor;
import net.icejz.api.module.system.UserTokenApi;
import net.icejz.system.service.SysUserTokenService;
import org.springframework.stereotype.Component;

/**
 * 用户令牌 API 实现
 */
@Component
@AllArgsConstructor
public class UserTokenApiImpl implements UserTokenApi {
    private final SysUserTokenService sysUserTokenService;

    @Override
    public void expireByAccessToken(String accessToken) {
        sysUserTokenService.expireByAccessToken(accessToken);
    }
}
