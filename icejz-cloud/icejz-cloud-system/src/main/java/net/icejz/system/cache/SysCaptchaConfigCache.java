package net.icejz.system.cache;

import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.cache.RedisCache;
import net.icejz.system.entity.SysCaptchaConfigEntity;
import org.springframework.stereotype.Service;

/**
 * 验证码配置缓存（按租户，JSON 存 Redis）
 */
@Service
@AllArgsConstructor
public class SysCaptchaConfigCache {
    private static final String KEY_PREFIX = "system:captcha:config:";

    private final RedisCache redisCache;

    public SysCaptchaConfigEntity get(Long tenantId) {
        Object raw = redisCache.get(KEY_PREFIX + tenantId);
        if (raw == null) {
            return null;
        }
        String json = raw instanceof String ? (String) raw : JSONUtil.toJsonStr(raw);
        if (StrUtil.isBlank(json)) {
            return null;
        }
        try {
            return JSONUtil.toBean(json, SysCaptchaConfigEntity.class);
        } catch (Exception e) {
            redisCache.delete(KEY_PREFIX + tenantId);
            return null;
        }
    }

    public void save(SysCaptchaConfigEntity entity) {
        if (entity == null || entity.getTenantId() == null) {
            return;
        }
        redisCache.set(KEY_PREFIX + entity.getTenantId(), JSONUtil.toJsonStr(entity), RedisCache.NOT_EXPIRE);
    }

    public void delete(Long tenantId) {
        redisCache.delete(KEY_PREFIX + tenantId);
    }
}
