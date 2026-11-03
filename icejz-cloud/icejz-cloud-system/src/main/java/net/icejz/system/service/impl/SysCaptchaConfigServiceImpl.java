package net.icejz.system.service.impl;

import cn.hutool.core.util.StrUtil;
import lombok.AllArgsConstructor;
import net.icejz.system.cache.SysParamsCache;
import net.icejz.system.dao.SysParamsDao;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.enums.SysParamsEnum;
import net.icejz.system.service.SysCaptchaConfigService;
import net.icejz.system.vo.SysCaptchaConfigVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 验证码类型配置
 */
@Service
@AllArgsConstructor
public class SysCaptchaConfigServiceImpl implements SysCaptchaConfigService {
    private final SysParamsDao sysParamsDao;
    private final SysParamsCache sysParamsCache;

    @Override
    public SysCaptchaConfigVO getConfig() {
        String legacy = safeGet(SysParamsEnum.LOGIN_CAPTCHA_TYPE.name(), "spec");
        SysCaptchaConfigVO vo = new SysCaptchaConfigVO();
        vo.setEnabled(Boolean.parseBoolean(safeGet(SysParamsEnum.LOGIN_CAPTCHA.name(), "false")));
        vo.setPcType(CaptchaTypeEnum.of(safeGet(SysParamsEnum.LOGIN_CAPTCHA_TYPE_PC.name(), legacy)).getCode());
        vo.setAppType(CaptchaTypeEnum.of(safeGet(SysParamsEnum.LOGIN_CAPTCHA_TYPE_APP.name(), legacy)).getCode());
        String sms = CaptchaTypeEnum.of(safeGet(SysParamsEnum.LOGIN_CAPTCHA_TYPE_SMS.name(), legacy)).getCode();
        vo.setSmsType(sms);
        vo.setMobileType(sms);
        vo.setTurnstileSiteKey(safeGet(SysParamsEnum.TURNSTILE_SITE_KEY.name(), ""));
        vo.setTurnstileSecretKey(safeGet(SysParamsEnum.TURNSTILE_SECRET_KEY.name(), ""));
        vo.setPowDifficulty(safeInt(SysParamsEnum.CAPTCHA_POW_DIFFICULTY.name(), 3));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveConfig(SysCaptchaConfigVO vo) {
        boolean enabled = Boolean.TRUE.equals(vo.getEnabled());
        upsert(SysParamsEnum.LOGIN_CAPTCHA.name(), "用户登录-验证码开关",
                String.valueOf(enabled), "是否开启账号登录图形验证码（true：开启，false：关闭）");

        String pc = CaptchaTypeEnum.of(vo.getPcType()).getCode();
        String app = CaptchaTypeEnum.of(vo.getAppType()).getCode();
        String smsRaw = StrUtil.blankToDefault(vo.getSmsType(), vo.getMobileType());
        String sms = CaptchaTypeEnum.of(StrUtil.blankToDefault(smsRaw, pc)).getCode();

        upsert(SysParamsEnum.LOGIN_CAPTCHA_TYPE_PC.name(), "PC管理端-账号登录验证码类型", pc,
                "PC 管理端账号登录使用的验证码类型");
        upsert(SysParamsEnum.LOGIN_CAPTCHA_TYPE_APP.name(), "移动端登录验证码类型", app,
                "App / 小程序 / H5 登录使用的验证码类型");
        upsert(SysParamsEnum.LOGIN_CAPTCHA_TYPE_SMS.name(), "短信发送-图形验证码类型", sms,
                "PC/App 发短信前图形验证码类型");
        upsert(SysParamsEnum.LOGIN_CAPTCHA_TYPE.name(), "用户登录-验证码类型(默认)", pc,
                "兼容旧配置；分端未配置时回退");

        upsert(SysParamsEnum.TURNSTILE_SITE_KEY.name(), "Turnstile站点公钥",
                StrUtil.nullToDefault(vo.getTurnstileSiteKey(), ""), "Cloudflare Turnstile Site Key");
        upsert(SysParamsEnum.TURNSTILE_SECRET_KEY.name(), "Turnstile密钥",
                StrUtil.nullToDefault(vo.getTurnstileSecretKey(), ""), "Cloudflare Turnstile Secret Key");

        int difficulty = vo.getPowDifficulty() == null ? 3 : vo.getPowDifficulty();
        difficulty = Math.max(2, Math.min(difficulty, 5));
        upsert(SysParamsEnum.CAPTCHA_POW_DIFFICULTY.name(), "PoW验证码难度",
                String.valueOf(difficulty), "PoW 前导0个数，建议2~4，越大越慢");
    }

    private void upsert(String key, String name, String value, String remark) {
        SysParamsEntity entity = sysParamsDao.get(key);
        if (entity == null) {
            entity = new SysParamsEntity();
            entity.setParamKey(key);
            entity.setParamName(name);
            entity.setParamValue(value);
            entity.setParamType(1);
            entity.setRemark(remark);
            entity.setTenantId(10000L);
            sysParamsDao.insert(entity);
        } else {
            entity.setParamName(name);
            entity.setParamValue(value);
            entity.setRemark(remark);
            sysParamsDao.updateById(entity);
        }
        sysParamsCache.save(key, value);
    }

    private String safeGet(String key, String defaultValue) {
        try {
            String cached = sysParamsCache.get(key);
            if (StrUtil.isNotBlank(cached)) {
                return cached;
            }
            SysParamsEntity entity = sysParamsDao.get(key);
            if (entity == null || StrUtil.isBlank(entity.getParamValue())) {
                return defaultValue;
            }
            sysParamsCache.save(entity.getParamKey(), entity.getParamValue());
            return entity.getParamValue();
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private int safeInt(String key, int defaultValue) {
        try {
            return Integer.parseInt(safeGet(key, String.valueOf(defaultValue)));
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
