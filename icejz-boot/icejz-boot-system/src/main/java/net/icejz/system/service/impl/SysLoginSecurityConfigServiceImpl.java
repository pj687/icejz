package net.icejz.system.service.impl;

import cn.hutool.core.util.StrUtil;
import lombok.AllArgsConstructor;
import net.icejz.system.cache.SysParamsCache;
import net.icejz.system.dao.SysParamsDao;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.enums.SysParamsEnum;
import net.icejz.system.service.SysLoginSecurityConfigService;
import net.icejz.system.vo.SysLoginSecurityConfigVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 登录安全配置
 */
@Service
@AllArgsConstructor
public class SysLoginSecurityConfigServiceImpl implements SysLoginSecurityConfigService {
    private final SysParamsDao sysParamsDao;
    private final SysParamsCache sysParamsCache;

    @Override
    public SysLoginSecurityConfigVO getConfig() {
        SysLoginSecurityConfigVO vo = new SysLoginSecurityConfigVO();
        vo.setMultiDeviceLogin(Boolean.parseBoolean(safeGet(SysParamsEnum.MULTI_DEVICE_LOGIN.name(), "false")));
        vo.setMultiDeviceMax(safeInt(SysParamsEnum.MULTI_DEVICE_MAX.name(), 5));
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveConfig(SysLoginSecurityConfigVO vo) {
        boolean multi = Boolean.TRUE.equals(vo.getMultiDeviceLogin());
        int max = vo.getMultiDeviceMax() == null ? 5 : vo.getMultiDeviceMax();
        max = Math.max(1, Math.min(max, 50));

        upsert(SysParamsEnum.MULTI_DEVICE_LOGIN.name(), "多设备登录开关",
                String.valueOf(multi), "是否允许多设备同时登录（true：多设备；false：单设备互踢）");
        upsert(SysParamsEnum.MULTI_DEVICE_MAX.name(), "多设备登录数量上限",
                String.valueOf(max), "多设备模式下同一账号最多同时在线会话数，超出踢最早");
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
            return Integer.parseInt(safeGet(key, String.valueOf(defaultValue)).trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
