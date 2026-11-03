package net.icejz.api.feign.system;

import net.icejz.api.feign.ServerNames;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 用户令牌 Feign（跨服务失效会话）
 */
@FeignClient(name = ServerNames.SYSTEM_SERVER_NAME, contextId = "userToken")
public interface UserTokenFeign {

    @PostMapping(value = "api/sys/token/expire")
    void expireByAccessToken(@RequestParam("accessToken") String accessToken);
}
