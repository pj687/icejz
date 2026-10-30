package net.icejz.framework.common.cache;

/**
 * Redis Key管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public class RedisKeys {

    /**
     * 验证码Key
     */
    public static String getCaptchaKey(String key) {
        return "sys:captcha:" + key;
    }

    /**
     * accessToken Key
     */
    public static String getAccessTokenKey(String accessToken) {
        return "sys:token:" + accessToken;
    }

    public static String getLogKey() {
        return "sys:log";
    }

}
