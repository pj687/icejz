package net.icejz.sms;

import java.util.Map;

/**
 * 短信
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public interface SmsStrategy {

    /**
     * 发送短信
     *
     * @param mobile 手机号
     * @param params 参数
     */
    void send(String mobile, Map<String, String> params);
}
