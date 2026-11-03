package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.cache.RedisKeys;
import net.icejz.framework.common.exception.ErrorCode;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.HttpContextUtils;
import net.icejz.framework.common.utils.IpUtils;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.cache.TokenStoreCache;
import net.icejz.framework.security.properties.SecurityProperties;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.framework.security.utils.TokenUtils;
import net.icejz.system.cache.SysParamsCache;
import net.icejz.system.dao.SysParamsDao;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.dao.SysUserTokenDao;
import net.icejz.system.entity.SysParamsEntity;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.entity.SysUserTokenEntity;
import net.icejz.system.enums.SysParamsEnum;
import net.icejz.system.service.SysUserDetailsService;
import net.icejz.system.service.SysUserTokenService;
import net.icejz.system.vo.SysUserDeviceVO;
import net.icejz.system.vo.SysUserTokenVO;
import org.springframework.http.HttpHeaders;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

/**
 * 用户Token
 *
 * @author ice_jz
 */
@Service
@AllArgsConstructor
public class SysUserTokenServiceImpl extends BaseServiceImpl<SysUserTokenDao, SysUserTokenEntity> implements SysUserTokenService {
    private final TokenStoreCache tokenStoreCache;
    private final SysUserDetailsService sysUserDetailsService;
    private final SecurityProperties securityProperties;
    private final SysUserDao sysUserDao;
    private final SysParamsCache sysParamsCache;
    private final SysParamsDao sysParamsDao;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysUserTokenVO createToken(Long userId) {
        String accessToken = TokenUtils.generator();
        String refreshToken = TokenUtils.generator();

        Date now = new Date();
        LocalDateTime accessExpire = DateUtil.toLocalDateTime(DateUtil.offsetSecond(now, securityProperties.getAccessTokenExpire()));
        LocalDateTime refreshExpire = DateUtil.toLocalDateTime(DateUtil.offsetSecond(now, securityProperties.getRefreshTokenExpire()));

        String loginIp = null;
        String userAgent = null;
        String clientType = "pc";
        HttpServletRequest request = HttpContextUtils.getHttpServletRequest();
        if (request != null) {
            loginIp = IpUtils.getIpAddr(request);
            userAgent = request.getHeader(HttpHeaders.USER_AGENT);
            clientType = resolveClientType(request, userAgent);
        }

        boolean systemMulti = Boolean.parseBoolean(safeParam(SysParamsEnum.MULTI_DEVICE_LOGIN.name(), "false"));
        int systemMax = safeIntParam(SysParamsEnum.MULTI_DEVICE_MAX.name(), 5);
        systemMax = Math.max(1, Math.min(systemMax, 50));

        boolean multiDevice = systemMulti;
        int multiMax = systemMax;
        SysUserEntity userCfg = sysUserDao.selectById(userId);
        if (userCfg != null) {
            if (userCfg.getMultiDeviceLogin() != null) {
                multiDevice = userCfg.getMultiDeviceLogin() == 1;
            }
            if (multiDevice && userCfg.getMultiDeviceMax() != null && userCfg.getMultiDeviceMax() > 0) {
                // 个人上限不可超过系统上限
                multiMax = Math.max(1, Math.min(userCfg.getMultiDeviceMax(), systemMax));
            }
        }

        SysUserTokenEntity entity = new SysUserTokenEntity();
        entity.setUserId(userId);
        entity.setAccessToken(accessToken);
        entity.setRefreshToken(refreshToken);
        entity.setAccessTokenExpire(accessExpire);
        entity.setRefreshTokenExpire(refreshExpire);
        entity.setLoginIp(loginIp);
        entity.setUserAgent(truncate(userAgent, 500));
        entity.setClientType(clientType);

        if (!multiDevice) {
            List<SysUserTokenEntity> oldList = baseMapper.selectList(
                    new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getUserId, userId)
                            .orderByAsc(SysUserTokenEntity::getId));
            for (SysUserTokenEntity old : oldList) {
                if (StrUtil.isNotBlank(old.getAccessToken())) {
                    tokenStoreCache.deleteUser(old.getAccessToken());
                }
            }
            if (oldList.isEmpty()) {
                baseMapper.insert(entity);
            } else {
                SysUserTokenEntity keep = oldList.get(0);
                entity.setId(keep.getId());
                baseMapper.updateById(entity);
                for (int i = 1; i < oldList.size(); i++) {
                    baseMapper.deleteById(oldList.get(i).getId());
                }
            }
        } else {
            baseMapper.insert(entity);
            List<SysUserTokenEntity> sessions = baseMapper.selectList(
                    new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getUserId, userId)
                            .orderByAsc(SysUserTokenEntity::getCreateTime)
                            .orderByAsc(SysUserTokenEntity::getId));
            int overflow = sessions.size() - multiMax;
            for (int i = 0; i < overflow; i++) {
                SysUserTokenEntity oldest = sessions.get(i);
                if (StrUtil.isNotBlank(oldest.getAccessToken())) {
                    tokenStoreCache.deleteUser(oldest.getAccessToken());
                }
                LocalDateTime expired = LocalDateTime.now();
                SysUserTokenEntity patch = new SysUserTokenEntity();
                patch.setId(oldest.getId());
                patch.setAccessTokenExpire(expired);
                patch.setRefreshTokenExpire(expired);
                baseMapper.updateById(patch);
            }
        }

        return BeanUtil.copyProperties(entity, SysUserTokenVO.class);
    }

    @Override
    public SysUserTokenVO refreshToken(String refreshToken) {
        LambdaQueryWrapper<SysUserTokenEntity> query = Wrappers.lambdaQuery();
        query.eq(SysUserTokenEntity::getRefreshToken, refreshToken);
        query.ge(SysUserTokenEntity::getRefreshTokenExpire, new Date());

        SysUserTokenEntity entity = baseMapper.selectOne(query);
        if (entity == null) {
            throw new ServerException(ErrorCode.REFRESH_TOKEN_INVALID);
        }

        tokenStoreCache.deleteUser(entity.getAccessToken());

        String accessToken = TokenUtils.generator();
        entity.setAccessToken(accessToken);
        entity.setAccessTokenExpire(DateUtil.toLocalDateTime(DateUtil.offsetSecond(new Date(), securityProperties.getAccessTokenExpire())));

        baseMapper.updateById(entity);

        SysUserEntity user = sysUserDao.selectById(entity.getUserId());
        UserDetail userDetail = BeanUtil.copyProperties(user, UserDetail.class);
        sysUserDetailsService.getUserDetails(userDetail);
        userDetail.setLoginIp(entity.getLoginIp());
        userDetail.setUserAgent(entity.getUserAgent());
        userDetail.setClientType(entity.getClientType());
        userDetail.setLoginTime(entity.getCreateTime());

        tokenStoreCache.saveUser(accessToken, userDetail);

        return BeanUtil.copyProperties(entity, SysUserTokenVO.class);
    }

    @Override
    public void expireToken(Long userId) {
        SysUserTokenEntity entity = new SysUserTokenEntity();
        LocalDateTime now = LocalDateTime.now();
        entity.setAccessTokenExpire(now);
        entity.setRefreshTokenExpire(now);

        baseMapper.update(entity, new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getUserId, userId));
    }

    @Override
    public void expireByAccessToken(String accessToken) {
        if (StrUtil.isBlank(accessToken)) {
            return;
        }
        tokenStoreCache.deleteUser(accessToken);

        SysUserTokenEntity entity = baseMapper.selectOne(
                new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getAccessToken, accessToken));
        if (entity == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        SysUserTokenEntity patch = new SysUserTokenEntity();
        patch.setId(entity.getId());
        patch.setAccessTokenExpire(now);
        patch.setRefreshTokenExpire(now);
        baseMapper.updateById(patch);
    }

    @Override
    public void forceLogoutByUserId(Long userId) {
        if (userId == null) {
            return;
        }
        List<String> accessTokenList = baseMapper.getOnlineAccessTokenListByUserId(userId, LocalDateTime.now());
        if (accessTokenList != null) {
            accessTokenList.forEach(tokenStoreCache::deleteUser);
        }
        // 兜底：清理 Redis 中仍残留的该用户会话
        for (SysUserDeviceVO device : listOnlineDevices(userId, null)) {
            if (StrUtil.isNotBlank(device.getAccessToken())) {
                tokenStoreCache.deleteUser(device.getAccessToken());
            }
        }
        expireToken(userId);
    }

    @Override
    public List<SysUserDeviceVO> listOnlineDevices(Long userId, String currentAccessToken) {
        return listOnlineDevices(userId, currentAccessToken, null);
    }

    @Override
    public List<SysUserDeviceVO> listOnlineDevices(Long userId, String currentAccessToken, HttpServletRequest request) {
        // 旧会话可能缺元数据：对本机从请求补全并写回
        if (StrUtil.isNotBlank(currentAccessToken) && request != null) {
            backfillSessionMeta(currentAccessToken, request);
        }

        List<SysUserDeviceVO> list = new ArrayList<>();
        List<String> keys = tokenStoreCache.getUserKeyList();
        String prefix = RedisKeys.getAccessTokenKey("");
        for (String key : keys) {
            String accessToken = key.startsWith(prefix) ? key.substring(prefix.length()) : key;
            UserDetail user = tokenStoreCache.getUser(accessToken);
            if (user == null || user.getId() == null || !user.getId().equals(userId)) {
                continue;
            }
            SysUserDeviceVO vo = new SysUserDeviceVO();
            vo.setAccessToken(accessToken);
            vo.setLoginIp(user.getLoginIp());
            vo.setUserAgent(user.getUserAgent());
            vo.setClientType(user.getClientType());
            vo.setLoginTime(user.getLoginTime());
            vo.setCurrent(StrUtil.isNotBlank(currentAccessToken) && currentAccessToken.equals(accessToken));

            // Redis 仍缺字段时，用 DB 行兜底
            if (StrUtil.isBlank(vo.getLoginIp()) || StrUtil.isBlank(vo.getUserAgent()) || StrUtil.isBlank(vo.getClientType()) || vo.getLoginTime() == null) {
                SysUserTokenEntity entity = baseMapper.selectOne(
                        new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getAccessToken, accessToken));
                if (entity != null) {
                    if (StrUtil.isBlank(vo.getLoginIp())) {
                        vo.setLoginIp(entity.getLoginIp());
                    }
                    if (StrUtil.isBlank(vo.getUserAgent())) {
                        vo.setUserAgent(entity.getUserAgent());
                    }
                    if (StrUtil.isBlank(vo.getClientType())) {
                        vo.setClientType(entity.getClientType());
                    }
                    if (vo.getLoginTime() == null) {
                        vo.setLoginTime(entity.getCreateTime());
                    }
                }
            }
            if (StrUtil.isBlank(vo.getClientType()) && StrUtil.isNotBlank(vo.getUserAgent())) {
                vo.setClientType(resolveClientTypeFromUa(vo.getUserAgent()));
            }
            list.add(vo);
        }
        list.sort(Comparator.comparing(SysUserDeviceVO::getLoginTime, Comparator.nullsLast(Comparator.reverseOrder())));
        return list;
    }

    private void backfillSessionMeta(String accessToken, HttpServletRequest request) {
        UserDetail user = tokenStoreCache.getUser(accessToken);
        if (user == null) {
            return;
        }
        boolean need = StrUtil.isBlank(user.getLoginIp()) || StrUtil.isBlank(user.getUserAgent())
                || StrUtil.isBlank(user.getClientType()) || user.getLoginTime() == null;
        if (!need) {
            return;
        }

        String loginIp = IpUtils.getIpAddr(request);
        String userAgent = request.getHeader(HttpHeaders.USER_AGENT);
        String clientType = resolveClientType(request, userAgent);
        LocalDateTime loginTime = user.getLoginTime() != null ? user.getLoginTime() : LocalDateTime.now();

        if (StrUtil.isBlank(user.getLoginIp())) {
            user.setLoginIp(loginIp);
        }
        if (StrUtil.isBlank(user.getUserAgent())) {
            user.setUserAgent(userAgent);
        }
        if (StrUtil.isBlank(user.getClientType())) {
            user.setClientType(clientType);
        }
        if (user.getLoginTime() == null) {
            user.setLoginTime(loginTime);
        }
        tokenStoreCache.updateUser(accessToken, user);

        SysUserTokenEntity entity = baseMapper.selectOne(
                new LambdaQueryWrapper<SysUserTokenEntity>().eq(SysUserTokenEntity::getAccessToken, accessToken));
        if (entity != null) {
            SysUserTokenEntity patch = new SysUserTokenEntity();
            patch.setId(entity.getId());
            boolean dirty = false;
            if (StrUtil.isBlank(entity.getLoginIp()) && StrUtil.isNotBlank(user.getLoginIp())) {
                patch.setLoginIp(user.getLoginIp());
                dirty = true;
            }
            if (StrUtil.isBlank(entity.getUserAgent()) && StrUtil.isNotBlank(user.getUserAgent())) {
                patch.setUserAgent(truncate(user.getUserAgent(), 500));
                dirty = true;
            }
            if (StrUtil.isBlank(entity.getClientType()) && StrUtil.isNotBlank(user.getClientType())) {
                patch.setClientType(user.getClientType());
                dirty = true;
            }
            if (dirty) {
                baseMapper.updateById(patch);
            }
        }
    }

    private String resolveClientTypeFromUa(String userAgent) {
        if (StrUtil.isBlank(userAgent)) {
            return "pc";
        }
        String ua = userAgent.toLowerCase();
        if (ua.contains("micromessenger")) {
            return "mp";
        }
        if (ua.contains("uni-app") || ua.contains("miniprogram") || ua.contains("android")
                || ua.contains("iphone") || ua.contains("ipad") || ua.contains("mobile")) {
            return "app";
        }
        return "pc";
    }

    @Async
    @Override
    public void updateCacheAuthByRoleId(Long roleId) {
        List<String> accessTokenList = baseMapper.getOnlineAccessTokenListByRoleId(roleId, LocalDateTime.now());
        accessTokenList.forEach(this::updateCacheAuth);
    }

    @Async
    @Override
    public void updateCacheAuthByUserId(Long userId) {
        List<String> accessTokenList = baseMapper.getOnlineAccessTokenListByUserId(userId, LocalDateTime.now());
        accessTokenList.forEach(this::updateCacheAuth);
    }

    private void updateCacheAuth(String accessToken) {
        UserDetail user = tokenStoreCache.getUser(accessToken);
        if (user == null) {
            return;
        }
        Long expire = tokenStoreCache.getExpire(accessToken);
        if (expire == null) {
            return;
        }
        sysUserDetailsService.getUserDetails(user);
        tokenStoreCache.saveUser(accessToken, user, expire);
    }

    private String resolveClientType(HttpServletRequest request, String userAgent) {
        String header = request.getHeader("X-Client-Type");
        if (StrUtil.isNotBlank(header)) {
            return header.trim().toLowerCase();
        }
        if (StrUtil.isBlank(userAgent)) {
            return "pc";
        }
        String ua = userAgent.toLowerCase();
        if (ua.contains("micromessenger")) {
            return "mp";
        }
        if (ua.contains("uni-app") || ua.contains("miniprogram") || ua.contains("android")
                || ua.contains("iphone") || ua.contains("ipad") || ua.contains("mobile")) {
            return "app";
        }
        return "pc";
    }

    private String safeParam(String key, String defaultValue) {
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

    private int safeIntParam(String key, int defaultValue) {
        try {
            return Integer.parseInt(safeParam(key, String.valueOf(defaultValue)).trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String truncate(String value, int max) {
        if (value == null) {
            return null;
        }
        return value.length() <= max ? value : value.substring(0, max);
    }
}
