package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import lombok.SneakyThrows;
import net.icejz.framework.common.constant.Constant;
import net.icejz.framework.common.excel.ExcelFinishCallBack;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.DateUtils;
import net.icejz.framework.common.utils.ExcelUtils;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.cache.TokenStoreCache;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.framework.security.utils.TokenUtils;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import net.icejz.system.enums.SuperAdminEnum;
import net.icejz.system.enums.UserStatusEnum;
import net.icejz.system.query.SysRoleUserQuery;
import net.icejz.system.query.SysUserQuery;
import net.icejz.system.service.SysLoginSecurityConfigService;
import net.icejz.system.service.SysMessageService;
import net.icejz.system.service.SysUserPostService;
import net.icejz.system.service.SysUserRoleService;
import net.icejz.system.service.SysUserService;
import net.icejz.system.service.SysUserTokenService;
import net.icejz.system.vo.*;
import net.icejz.framework.common.trans.TransService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysUserServiceImpl extends BaseServiceImpl<SysUserDao, SysUserEntity> implements SysUserService {
    private final SysUserRoleService sysUserRoleService;
    private final SysUserPostService sysUserPostService;
    private final SysUserTokenService sysUserTokenService;
    private final SysMessageService sysMessageService;
    private final SysLoginSecurityConfigService sysLoginSecurityConfigService;
    private final TokenStoreCache tokenStoreCache;
    private final TransService transService;

    @Override
    public PageResult<SysUserVO> page(SysUserQuery query) {
        // 查询参数
        Map<String, Object> params = getParams(query);

        // 分页查询
        IPage<SysUserEntity> page = getPage(query);
        params.put(Constant.PAGE, page);

        // 数据列表
        List<SysUserEntity> list = baseMapper.getList(params);

        return new PageResult<>(BeanUtil.copyToList(list, SysUserVO.class), page.getTotal());
    }

    @Override
    public SysUserVO getDetail(Long id) {
        SysUserEntity entity = baseMapper.getById(id);
        if (entity == null) {
            throw new ServerException("用户不存在");
        }
        SysUserVO vo = BeanUtil.copyProperties(entity, SysUserVO.class);
        vo.setRoleIdList(sysUserRoleService.getRoleIdList(id));
        List<Long> postIdList = sysUserPostService.getPostIdList(id);
        vo.setPostIdList(postIdList);
        return vo;
    }

    private Map<String, Object> getParams(SysUserQuery query) {
        Map<String, Object> params = new HashMap<>();
        params.put("username", query.getUsername());
        params.put("mobile", query.getMobile());
        params.put("gender", query.getGender());

        // 数据权限
        // params.put(Constant.DATA_SCOPE, getDataScope("t1", null));

        // 机构过滤
        if (ObjectUtil.isNotEmpty(query.getOrgId())) {
            params.put("orgList", query.getOrgId());
        }

        return params;
    }


    @Override
    @Transactional(rollbackFor = Exception.class)
    public void save(SysUserVO vo) {
        SysUserEntity entity = BeanUtil.copyProperties(vo, SysUserEntity.class);
        entity.setSuperAdmin(SuperAdminEnum.NO.getValue());
        normalizeUserMultiDevice(entity);

        // 判断用户名是否存在
        SysUserEntity user = baseMapper.getByUsername(entity.getUsername());
        if (user != null) {
            throw new ServerException("用户名已经存在");
        }

        // 判断手机号是否存在
        user = baseMapper.getByMobile(entity.getMobile());
        if (user != null) {
            throw new ServerException("手机号已经存在");
        }

        // 保存用户
        baseMapper.insert(entity);

        // 保存用户角色关系
        sysUserRoleService.saveOrUpdate(entity.getId(), vo.getRoleIdList());

        // 更新用户岗位关系
        sysUserPostService.saveOrUpdate(entity.getId(), vo.getPostIdList());
    }

    @Override
    public void update(SysUserVO vo) {
        SysUserEntity entity = BeanUtil.copyProperties(vo, SysUserEntity.class);
        normalizeUserMultiDevice(entity);

        // 判断用户名是否存在
        SysUserEntity user = baseMapper.getByUsername(entity.getUsername());
        if (user != null && !user.getId().equals(entity.getId())) {
            throw new ServerException("用户名已经存在");
        }

        // 判断手机号是否存在
        user = baseMapper.getByMobile(entity.getMobile());
        if (user != null && !user.getId().equals(entity.getId())) {
            throw new ServerException("手机号已经存在");
        }

        // 更新用户
        updateById(entity);

        // 更新用户角色关系
        sysUserRoleService.saveOrUpdate(entity.getId(), vo.getRoleIdList());

        // 更新用户岗位关系
        sysUserPostService.saveOrUpdate(entity.getId(), vo.getPostIdList());

        // 更新用户缓存权限
        sysUserTokenService.updateCacheAuthByUserId(entity.getId());

        // 编辑时若改为封禁，立即踢下线
        if (entity.getStatus() != null && entity.getStatus() == UserStatusEnum.DISABLE.getValue()) {
            sysUserTokenService.forceLogoutByUserId(entity.getId());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(SysUserStatusVO vo) {
        if (vo == null || vo.getId() == null) {
            throw new ServerException("用户不存在");
        }
        Integer status = vo.getStatus();
        if (status == null || (status != UserStatusEnum.DISABLE.getValue() && status != UserStatusEnum.ENABLED.getValue())) {
            throw new ServerException("状态值无效");
        }
        Long id = vo.getId();
        if (id.equals(SecurityUser.getUserId())) {
            throw new ServerException("不能封禁当前登录用户");
        }

        SysUserEntity user = getById(id);
        if (user == null) {
            throw new ServerException("用户不存在");
        }
        if (ObjectUtil.equal(user.getSuperAdmin(), SuperAdminEnum.YES.getValue())) {
            throw new ServerException("不能封禁超级管理员");
        }

        boolean sendNotify = Boolean.TRUE.equals(vo.getSendNotify());
        String reason = StrUtil.trim(vo.getReason());

        if (status == UserStatusEnum.DISABLE.getValue()) {
            LocalDateTime expireTime = resolveBanExpireTime(vo);
            // 先发通知（接收人须仍为正常状态），再封禁踢线
            if (sendNotify) {
                sendBanNotify(user, true, reason, expireTime);
            }

            LambdaUpdateWrapper<SysUserEntity> uw = Wrappers.lambdaUpdate();
            uw.eq(SysUserEntity::getId, id)
                    .set(SysUserEntity::getStatus, UserStatusEnum.DISABLE.getValue())
                    .set(SysUserEntity::getBanReason, StrUtil.blankToDefault(reason, null))
                    .set(SysUserEntity::getBanTime, LocalDateTime.now())
                    .set(SysUserEntity::getBanExpireTime, expireTime);
            update(uw);
            sysUserTokenService.forceLogoutByUserId(id);
        } else {
            if (sendNotify) {
                // 解封通知：此时若仍是封禁态，resolveReceivers 会过滤，先临时改状态再通知不合适；
                // 直接解封后再发
            }

            LambdaUpdateWrapper<SysUserEntity> uw = Wrappers.lambdaUpdate();
            uw.eq(SysUserEntity::getId, id)
                    .set(SysUserEntity::getStatus, UserStatusEnum.ENABLED.getValue())
                    .set(SysUserEntity::getBanReason, null)
                    .set(SysUserEntity::getBanTime, null)
                    .set(SysUserEntity::getBanExpireTime, null);
            update(uw);
            sysUserTokenService.updateCacheAuthByUserId(id);

            if (sendNotify) {
                sendBanNotify(user, false, reason, null);
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysUserEntity releaseIfBanExpired(SysUserEntity user) {
        if (user == null) {
            return null;
        }
        if (!ObjectUtil.equal(user.getStatus(), UserStatusEnum.DISABLE.getValue())) {
            return user;
        }
        LocalDateTime expire = user.getBanExpireTime();
        if (expire == null || expire.isAfter(LocalDateTime.now())) {
            return user;
        }
        LambdaUpdateWrapper<SysUserEntity> uw = Wrappers.lambdaUpdate();
        uw.eq(SysUserEntity::getId, user.getId())
                .set(SysUserEntity::getStatus, UserStatusEnum.ENABLED.getValue())
                .set(SysUserEntity::getBanReason, null)
                .set(SysUserEntity::getBanTime, null)
                .set(SysUserEntity::getBanExpireTime, null);
        update(uw);
        user.setStatus(UserStatusEnum.ENABLED.getValue());
        user.setBanReason(null);
        user.setBanTime(null);
        user.setBanExpireTime(null);
        return user;
    }

    @Override
    public String getLoginBanTip(SysUserEntity user) {
        if (user == null || !ObjectUtil.equal(user.getStatus(), UserStatusEnum.DISABLE.getValue())) {
            return "抱歉，您的账号暂时无法登录，请联系管理员。";
        }
        StringBuilder tip = new StringBuilder("抱歉，您的账号已被封禁，暂时无法登录。");
        if (StrUtil.isNotBlank(user.getBanReason())) {
            tip.append("封禁原因：").append(user.getBanReason().trim()).append("。");
        }
        LocalDateTime expire = user.getBanExpireTime();
        if (expire == null) {
            tip.append("解封时间：永久封禁。");
        } else {
            tip.append("预计解封时间：")
                    .append(expire.format(DateTimeFormatter.ofPattern(DateUtils.DATE_TIME_PATTERN)))
                    .append("。");
        }
        tip.append("如有疑问，请联系系统管理员。");
        return tip.toString();
    }

    private LocalDateTime resolveBanExpireTime(SysUserStatusVO vo) {
        String duration = StrUtil.blankToDefault(vo.getBanDuration(), "permanent").trim().toLowerCase();
        LocalDateTime now = LocalDateTime.now();
        return switch (duration) {
            case "5m" -> now.plusMinutes(5);
            case "10m" -> now.plusMinutes(10);
            case "15m" -> now.plusMinutes(15);
            case "30m" -> now.plusMinutes(30);
            case "1h" -> now.plusHours(1);
            case "6h" -> now.plusHours(6);
            case "12h" -> now.plusHours(12);
            case "1d" -> now.plusDays(1);
            case "3d" -> now.plusDays(3);
            case "7d" -> now.plusDays(7);
            case "15d" -> now.plusDays(15);
            case "30d" -> now.plusDays(30);
            case "90d" -> now.plusDays(90);
            case "custom" -> {
                if (vo.getBanExpireTime() == null) {
                    throw new ServerException("请选择封禁到期时间");
                }
                if (!vo.getBanExpireTime().isAfter(now)) {
                    throw new ServerException("封禁到期时间必须晚于当前时间");
                }
                yield vo.getBanExpireTime();
            }
            default -> null; // permanent
        };
    }

    private void sendBanNotify(SysUserEntity target, boolean banned, String reason, LocalDateTime expireTime) {
        try {
            SysMessageVO msg = new SysMessageVO();
            msg.setType(0);
            msg.setReceiverType(1);
            msg.setReceiverIdList(List.of(target.getId()));
            if (banned) {
                String expireText = expireTime == null ? "永久" : expireTime.toString().replace('T', ' ');
                msg.setTitle("账号封禁通知");
                msg.setContent("您的账号已被管理员封禁。"
                        + "\n封禁时长：" + expireText
                        + (StrUtil.isNotBlank(reason) ? ("\n封禁原因：" + reason) : "")
                        + "\n封禁期间将无法登录系统，如有疑问请联系管理员。");
            } else {
                msg.setTitle("账号解封通知");
                msg.setContent("您的账号已解除封禁，可重新登录使用。"
                        + (StrUtil.isNotBlank(reason) ? ("\n备注：" + reason) : ""));
            }
            sysMessageService.send(msg);
        } catch (Exception ignored) {
            // 通知失败不影响封禁主流程
        }
    }

    @Override
    public void updateLoginInfo(SysUserBaseVO vo) {
        SysUserEntity entity = BeanUtil.copyProperties(vo, SysUserEntity.class);
        // 设置登录用户ID
        entity.setId(SecurityUser.getUserId());

        // 判断手机号是否存在
        SysUserEntity user = baseMapper.getByMobile(entity.getMobile());
        if (user != null && !user.getId().equals(entity.getId())) {
            throw new ServerException("手机号已经存在");
        }

        // 更新用户
        updateById(entity);

        // 更新缓存逻辑
        String accessToken = TokenUtils.getAccessToken();
        UserDetail cacheUser = tokenStoreCache.getUser(accessToken);
        cacheUser.setRealName(vo.getRealName());
        cacheUser.setMobile(vo.getMobile());
        cacheUser.setEmail(vo.getEmail());
        cacheUser.setGender(vo.getGender());
        // 更新操作
        tokenStoreCache.updateUser(accessToken, cacheUser);
    }

    @Override
    public SysUserLoginSecurityVO getMyLoginSecurity() {
        Long userId = SecurityUser.getUserId();
        SysUserEntity user = getById(userId);
        if (user == null) {
            throw new ServerException("用户不存在");
        }
        SysLoginSecurityConfigVO system = sysLoginSecurityConfigService.getConfig();
        boolean systemMulti = Boolean.TRUE.equals(system.getMultiDeviceLogin());
        int systemMax = system.getMultiDeviceMax() == null ? 5 : system.getMultiDeviceMax();

        SysUserLoginSecurityVO vo = new SysUserLoginSecurityVO();
        vo.setSystemMultiDeviceLogin(systemMulti);
        vo.setSystemMultiDeviceMax(systemMax);
        vo.setMultiDeviceLogin(user.getMultiDeviceLogin());
        vo.setMultiDeviceMax(user.getMultiDeviceMax());

        boolean effectiveMulti = user.getMultiDeviceLogin() == null ? systemMulti : user.getMultiDeviceLogin() == 1;
        int effectiveMax = systemMax;
        if (effectiveMulti && user.getMultiDeviceMax() != null && user.getMultiDeviceMax() > 0) {
            // 个人上限不可超过系统上限
            effectiveMax = Math.max(1, Math.min(user.getMultiDeviceMax(), systemMax));
        }
        vo.setEffectiveMultiDeviceLogin(effectiveMulti);
        vo.setEffectiveMultiDeviceMax(effectiveMax);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMyLoginSecurity(SysUserLoginSecurityVO vo) {
        Long userId = SecurityUser.getUserId();
        Integer mode = vo == null ? null : vo.getMultiDeviceLogin();
        Integer max = vo == null ? null : vo.getMultiDeviceMax();
        if (mode != null && mode != 0 && mode != 1) {
            throw new ServerException("多设备设置无效");
        }
        int systemMax = resolveSystemMultiDeviceMax();
        if (mode == null || mode == 0) {
            max = null;
        } else {
            if (max == null) {
                max = systemMax;
            }
            max = Math.max(1, Math.min(max, systemMax));
        }

        LambdaUpdateWrapper<SysUserEntity> uw = Wrappers.lambdaUpdate();
        uw.eq(SysUserEntity::getId, userId)
                .set(SysUserEntity::getMultiDeviceLogin, mode)
                .set(SysUserEntity::getMultiDeviceMax, max);
        update(uw);
    }

    /** 个人/用户级设备上限不得超过系统登录安全配置 */
    private int resolveSystemMultiDeviceMax() {
        SysLoginSecurityConfigVO system = sysLoginSecurityConfigService.getConfig();
        int systemMax = system.getMultiDeviceMax() == null ? 5 : system.getMultiDeviceMax();
        return Math.max(1, Math.min(systemMax, 50));
    }

    private void normalizeUserMultiDevice(SysUserEntity entity) {
        if (entity == null) {
            return;
        }
        Integer mode = entity.getMultiDeviceLogin();
        if (mode != null && mode != 0 && mode != 1) {
            throw new ServerException("多设备设置无效");
        }
        if (mode == null || mode == 0) {
            entity.setMultiDeviceMax(null);
            return;
        }
        int systemMax = resolveSystemMultiDeviceMax();
        Integer max = entity.getMultiDeviceMax();
        if (max == null) {
            entity.setMultiDeviceMax(systemMax);
            return;
        }
        entity.setMultiDeviceMax(Math.max(1, Math.min(max, systemMax)));
    }

    @Override
    public void updateAvatar(SysUserAvatarVO avatar) {
        SysUserEntity entity = new SysUserEntity();
        entity.setId(SecurityUser.getUserId());
        entity.setAvatar(avatar.getAvatar());
        updateById(entity);

        // 更新缓存逻辑
        String accessToken = TokenUtils.getAccessToken();
        UserDetail cacheUser = tokenStoreCache.getUser(accessToken);
        cacheUser.setAvatar(avatar.getAvatar());
        // 更新操作
        tokenStoreCache.updateUser(accessToken, cacheUser);
    }

    @Override
    public void updateSignature(SysUserSignatureVO signature) {
        SysUserEntity entity = new SysUserEntity();
        entity.setId(SecurityUser.getUserId());
        entity.setSignature(signature.getSignature());
        updateById(entity);

        // 更新缓存逻辑
        String accessToken = TokenUtils.getAccessToken();
        UserDetail cacheUser = tokenStoreCache.getUser(accessToken);
        cacheUser.setSignature(signature.getSignature());
        // 更新操作
        tokenStoreCache.updateUser(accessToken, cacheUser);
    }

    @Override
    public void delete(List<Long> idList) {
        // 删除用户
        removeByIds(idList);

        // 删除用户角色关系
        sysUserRoleService.deleteByUserIdList(idList);

        // 删除用户岗位关系
        sysUserPostService.deleteByUserIdList(idList);
    }

    @Override
    public List<String> getRealNameList(List<Long> idList) {
        if (idList.isEmpty()) {
            return null;
        }

        return baseMapper.selectBatchIds(idList).stream().map(SysUserEntity::getRealName).toList();
    }

    @Override
    public List<SysUserVO> getOrgUserList(Long orgId) {
        LambdaQueryWrapper<SysUserEntity> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SysUserEntity::getOrgId, orgId);

        List<SysUserEntity> list = baseMapper.selectList(queryWrapper);

        return BeanUtil.copyToList(list, SysUserVO.class);
    }

    @Override
    public SysUserVO getByMobile(String mobile) {
        SysUserEntity user = baseMapper.getByMobile(mobile);

        return BeanUtil.copyProperties(user, SysUserVO.class);
    }

    @Override
    public void updatePassword(Long id, String newPassword) {
        // 修改密码
        SysUserEntity user = getById(id);
        user.setPassword(newPassword);

        updateById(user);
    }

    @Override
    public PageResult<SysUserVO> roleUserPage(SysRoleUserQuery query) {
        // 查询参数
        Map<String, Object> params = getParams(query);
        params.put("roleId", query.getRoleId());

        // 分页查询
        IPage<SysUserEntity> page = getPage(query);
        params.put(Constant.PAGE, page);

        // 数据列表
        List<SysUserEntity> list = baseMapper.getRoleUserList(params);

        return new PageResult<>(BeanUtil.copyToList(list, SysUserVO.class), page.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void importByExcel(MultipartFile file, String password) {
        ExcelUtils.readAnalysis(file, SysUserExcelVO.class, new ExcelFinishCallBack<>() {
            @Override
            public void doSaveBatch(List<SysUserExcelVO> result) {
                ExcelUtils.parseDict(result);
                List<SysUserEntity> userList = BeanUtil.copyToList(result, SysUserEntity.class);
                userList.forEach(user -> user.setPassword(password));
                saveBatch(userList);
            }
        });
    }

    @Override
    @SneakyThrows
    public void export() {
        List<SysUserEntity> list = list(Wrappers.lambdaQuery(SysUserEntity.class).eq(SysUserEntity::getSuperAdmin, SuperAdminEnum.NO.getValue()));
        List<SysUserExcelVO> userExcelVOS = BeanUtil.copyToList(list, SysUserExcelVO.class);
        transService.transBatch(userExcelVOS);
        // 写到浏览器打开
        ExcelUtils.excelExport(SysUserExcelVO.class, "用户管理", null, userExcelVOS);
    }

}
