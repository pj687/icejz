package net.icejz.system.cache;

import lombok.AllArgsConstructor;
import net.icejz.framework.common.cache.RedisCache;
import net.icejz.framework.common.exception.ServerException;
import org.springframework.stereotype.Service;

/**
 * 短信发送 Cache
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SmsSendCache {
    private final RedisCache redisCache;

    /**
     * 获取发送手机短信验证码KEY
     *
     * @param mobile 手机号
     * @return KEY
     */
    private String getCodeKey(String mobile) {
        return "sys:sms:code" + mobile;
    }

    private String getIntervalKey(String mobile) {
        return "sys:sms:interval:" + mobile;
    }

    private String getHourKey(String mobile) {
        return "sys:sms:hour:" + mobile;
    }

    public void saveCode(String mobile, String code) {
        String key = getCodeKey(mobile);

        // 保存到Redis，有效期10分钟
        redisCache.set(key, code, 10 * 60);
    }

    public String getCode(String mobile) {
        String key = getCodeKey(mobile);
        return (String) redisCache.get(key);
    }

    public void deleteCode(String mobile) {
        String key = getCodeKey(mobile);
        redisCache.delete(key);
    }

    /**
     * 发送前频控：最小间隔 + 每小时上限
     */
    public void checkSendLimit(String mobile, int intervalSeconds, int hourLimit) {
        if (Boolean.TRUE.equals(redisCache.hasKey(getIntervalKey(mobile)))) {
            throw new ServerException("发送过于频繁，请稍后再试");
        }
        Long count = redisCache.increment(getHourKey(mobile));
        if (count != null && count == 1L) {
            redisCache.expire(getHourKey(mobile), 3600);
        }
        if (count != null && count > hourLimit) {
            throw new ServerException("该手机号今日发送次数已达上限，请稍后再试");
        }
    }

    /**
     * 发送成功后写入间隔锁
     */
    public void markSent(String mobile, int intervalSeconds) {
        redisCache.set(getIntervalKey(mobile), "1", Math.max(intervalSeconds, 30));
    }
}
