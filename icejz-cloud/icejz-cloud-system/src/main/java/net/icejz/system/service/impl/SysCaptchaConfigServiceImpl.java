package net.icejz.system.service.impl;

import cn.hutool.core.util.StrUtil;
import lombok.AllArgsConstructor;
import net.icejz.system.cache.SysCaptchaConfigCache;
import net.icejz.system.dao.SysCaptchaConfigDao;
import net.icejz.system.entity.SysCaptchaConfigEntity;
import net.icejz.system.enums.CaptchaChannelEnum;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.service.SysCaptchaConfigService;
import net.icejz.system.vo.SysCaptchaConfigVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 验证码配置（sys_captcha_config）
 */
@Service
@AllArgsConstructor
public class SysCaptchaConfigServiceImpl implements SysCaptchaConfigService {
    private static final long DEFAULT_TENANT_ID = 10000L;

    private final SysCaptchaConfigDao sysCaptchaConfigDao;
    private final SysCaptchaConfigCache sysCaptchaConfigCache;

    @Override
    public SysCaptchaConfigVO getConfig() {
        SysCaptchaConfigEntity entity = loadOrCreate(DEFAULT_TENANT_ID);
        return toVo(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveConfig(SysCaptchaConfigVO vo) {
        SysCaptchaConfigEntity entity = loadOrCreate(DEFAULT_TENANT_ID);

        String pc = CaptchaTypeEnum.of(vo.getPcType()).getCode();
        String app = CaptchaTypeEnum.of(vo.getAppType()).getCode();
        String smsRaw = StrUtil.blankToDefault(vo.getSmsType(), vo.getMobileType());
        String sms = CaptchaTypeEnum.of(StrUtil.blankToDefault(smsRaw, pc)).getCode();
        int difficulty = vo.getPowDifficulty() == null ? 3 : vo.getPowDifficulty();
        difficulty = Math.max(2, Math.min(difficulty, 5));

        entity.setEnabled(Boolean.TRUE.equals(vo.getEnabled()) ? 1 : 0);
        entity.setPcType(pc);
        entity.setAppType(app);
        entity.setSmsType(sms);
        entity.setTurnstileSiteKey(StrUtil.nullToDefault(vo.getTurnstileSiteKey(), ""));
        entity.setTurnstileSecretKey(StrUtil.nullToDefault(vo.getTurnstileSecretKey(), ""));
        entity.setPowDifficulty(difficulty);

        sysCaptchaConfigDao.updateById(entity);
        sysCaptchaConfigCache.delete(entity.getTenantId());
        sysCaptchaConfigCache.save(entity);
    }

    @Override
    public boolean isEnabled() {
        return Integer.valueOf(1).equals(loadOrCreate(DEFAULT_TENANT_ID).getEnabled());
    }

    @Override
    public CaptchaTypeEnum resolveType(CaptchaChannelEnum channel) {
        SysCaptchaConfigEntity entity = loadOrCreate(DEFAULT_TENANT_ID);
        String code = switch (channel == null ? CaptchaChannelEnum.PC : channel) {
            case APP -> entity.getAppType();
            case SMS -> entity.getSmsType();
            default -> entity.getPcType();
        };
        return CaptchaTypeEnum.of(code);
    }

    @Override
    public String getTurnstileSiteKey() {
        return StrUtil.nullToDefault(loadOrCreate(DEFAULT_TENANT_ID).getTurnstileSiteKey(), "");
    }

    @Override
    public String getTurnstileSecretKey() {
        return StrUtil.nullToDefault(loadOrCreate(DEFAULT_TENANT_ID).getTurnstileSecretKey(), "");
    }

    @Override
    public int getPowDifficulty() {
        Integer d = loadOrCreate(DEFAULT_TENANT_ID).getPowDifficulty();
        if (d == null) {
            return 3;
        }
        return Math.max(2, Math.min(d, 5));
    }

    private SysCaptchaConfigEntity loadOrCreate(Long tenantId) {
        SysCaptchaConfigEntity cached = sysCaptchaConfigCache.get(tenantId);
        if (cached != null) {
            return cached;
        }
        SysCaptchaConfigEntity entity = sysCaptchaConfigDao.getByTenantId(tenantId);
        if (entity == null) {
            entity = defaultEntity(tenantId);
            sysCaptchaConfigDao.insert(entity);
        }
        sysCaptchaConfigCache.save(entity);
        return entity;
    }

    private SysCaptchaConfigEntity defaultEntity(Long tenantId) {
        SysCaptchaConfigEntity entity = new SysCaptchaConfigEntity();
        entity.setTenantId(tenantId);
        entity.setEnabled(0);
        entity.setPcType(CaptchaTypeEnum.SPEC.getCode());
        entity.setAppType(CaptchaTypeEnum.SPEC.getCode());
        entity.setSmsType(CaptchaTypeEnum.SPEC.getCode());
        entity.setTurnstileSiteKey("");
        entity.setTurnstileSecretKey("");
        entity.setPowDifficulty(3);
        entity.setRemark("系统默认验证码配置");
        return entity;
    }

    private SysCaptchaConfigVO toVo(SysCaptchaConfigEntity entity) {
        SysCaptchaConfigVO vo = new SysCaptchaConfigVO();
        vo.setEnabled(Integer.valueOf(1).equals(entity.getEnabled()));
        vo.setPcType(CaptchaTypeEnum.of(entity.getPcType()).getCode());
        vo.setAppType(CaptchaTypeEnum.of(entity.getAppType()).getCode());
        String sms = CaptchaTypeEnum.of(entity.getSmsType()).getCode();
        vo.setSmsType(sms);
        vo.setMobileType(sms);
        vo.setTurnstileSiteKey(StrUtil.nullToDefault(entity.getTurnstileSiteKey(), ""));
        vo.setTurnstileSecretKey(StrUtil.nullToDefault(entity.getTurnstileSecretKey(), ""));
        vo.setPowDifficulty(entity.getPowDifficulty() == null ? 3 : entity.getPowDifficulty());
        return vo;
    }
}
