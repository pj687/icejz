package net.icejz.monitor.controller;

import cn.hutool.core.collection.ListUtil;
import cn.hutool.core.util.StrUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.api.module.system.UserTokenApi;
import net.icejz.framework.common.cache.RedisCache;
import net.icejz.framework.common.cache.RedisKeys;
import net.icejz.framework.common.query.Query;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.security.cache.TokenStoreCache;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.monitor.vo.UserOnlineVO;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("monitor/user")
@AllArgsConstructor
@Tag(name = "在线用户监控")
public class UserOnlineController {
    private final TokenStoreCache tokenStoreCache;
    private final RedisCache redisCache;
    private final UserTokenApi userTokenApi;

    @GetMapping("page")
    @Operation(summary = "分页")
    @PreAuthorize("hasAuthority('monitor:user:all')")
    public Result<PageResult<UserOnlineVO>> page(@ParameterObject @Valid Query query) {
        List<String> keys = tokenStoreCache.getUserKeyList();
        List<String> keyList = ListUtil.page(query.getPage() - 1, query.getLimit(), keys);

        List<UserOnlineVO> userOnlineList = new ArrayList<>();
        String prefix = RedisKeys.getAccessTokenKey("");
        keyList.forEach(key -> {
            UserDetail user = (UserDetail) redisCache.get(key);
            if (user != null) {
                UserOnlineVO userOnlineVO = new UserOnlineVO();
                userOnlineVO.setId(user.getId());
                userOnlineVO.setUsername(user.getUsername());
                userOnlineVO.setRealName(user.getRealName());
                userOnlineVO.setGender(user.getGender());
                userOnlineVO.setEmail(user.getEmail());
                userOnlineVO.setAccessToken(key.startsWith(prefix) ? key.substring(prefix.length()) : key.replace(prefix, ""));
                userOnlineVO.setLoginIp(user.getLoginIp());
                userOnlineVO.setUserAgent(user.getUserAgent());
                userOnlineVO.setClientType(user.getClientType());
                userOnlineVO.setLoginTime(user.getLoginTime());
                userOnlineList.add(userOnlineVO);
            }
        });

        return Result.ok(new PageResult<>(userOnlineList, keys.size()));
    }

    @DeleteMapping("{accessToken}")
    @Operation(summary = "强制退出")
    @PreAuthorize("hasAuthority('monitor:user:all')")
    public Result<String> forceLogout(@PathVariable("accessToken") String accessToken) {
        if (StrUtil.isBlank(accessToken)) {
            return Result.error("token不能为空");
        }
        userTokenApi.expireByAccessToken(accessToken);
        return Result.ok();
    }
}
