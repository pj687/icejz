package net.icejz.system.api;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.icejz.api.module.system.SmsApi;
import net.icejz.sms.service.SmsService;
import net.icejz.system.cache.SmsSendCache;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * 短信服务Api
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SmsApiImpl implements SmsApi {
    private final SmsService smsService;
    private final SmsSendCache smsSendCache;

    @Value("${icejz.sms.mock:false}")
    private boolean mock;

    @Override
    public boolean send(String mobile, Map<String, String> params) {
        return smsService.send(mobile, params);
    }

    @Override
    public boolean send(String groupName, String mobile, Map<String, String> params) {
        return smsService.send(groupName, mobile, params);
    }

    @Override
    public boolean sendCode(String mobile, String key, String value) {
        smsSendCache.saveCode(mobile, value);

        if (mock) {
            log.info("[SMS-MOCK] mobile={}, code={}", mobile, value);
            return true;
        }

        Map<String, String> params = new HashMap<>();
        params.put(key, value);
        return smsService.send(mobile, params);
    }

    @Override
    public boolean sendCode(String groupName, String mobile, String key, String value) {
        smsSendCache.saveCode(mobile, value);

        if (mock) {
            log.info("[SMS-MOCK] group={}, mobile={}, code={}", groupName, mobile, value);
            return true;
        }

        Map<String, String> params = new HashMap<>();
        params.put(key, value);
        return smsService.send(groupName, mobile, params);
    }

    @Override
    public boolean verifyCode(String mobile, String code) {
        String value = smsSendCache.getCode(mobile);
        if (value != null) {
            smsSendCache.deleteCode(mobile);
            return value.equalsIgnoreCase(code);
        }

        return false;
    }
}
