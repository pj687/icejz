package net.icejz.system.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fhs.trans.service.impl.TransService;
import lombok.AllArgsConstructor;
import lombok.SneakyThrows;
import net.icejz.framework.common.constant.Constant;
import net.icejz.framework.common.excel.ExcelFinishCallBack;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.ExcelUtils;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.cache.TokenStoreCache;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.utils.TokenUtils;
import net.icejz.system.convert.SysUserConvert;
import net.icejz.system.dao.SysUserDao;
import net.icejz.system.entity.SysUserEntity;
import cn.hutool.core.util.ObjectUtil;
import net.icejz.system.enums.SuperAdminEnum;
import net.icejz.system.enums.UserStatusEnum;
import net.icejz.system.query.SysRoleUserQuery;
import net.icejz.system.query.SysUserQuery;
import net.icejz.system.service.*;
import net.icejz.system.vo.SysUserAvatarVO;
import net.icejz.system.vo.SysUserBaseVO;
import net.icejz.system.vo.SysUserExcelVO;
import net.icejz.system.vo.SysUserVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

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
    private final SysOrgService sysOrgService;
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

        return new PageResult<>(SysUserConvert.INSTANCE.convertList(list), page.getTotal());
    }

    private Map<String, Object> getParams(SysUserQuery query) {
        Map<String, Object> params = new HashMap<>();
        params.put("username", query.getUsername());
        params.put("mobile", query.getMobile());
        params.put("gender", query.getGender());

        // 数据权限
        params.put(Constant.DATA_SCOPE, getDataScope("t1", null));

        // 机构过滤
        if (query.getOrgId() != null) {
            // 查询子机构ID列表，包含本机构
            List<Long> orgList = sysOrgService.getSubOrgIdList(query.getOrgId());
            params.put("orgList", orgList);
        }

        return params;
    }


    @Override
    @Transactional(rollbackFor = Exception.class)
    public void save(SysUserVO vo) {
        SysUserEntity entity = SysUserConvert.INSTANCE.convert(vo);
        entity.setSuperAdmin(SuperAdminEnum.NO.getValue());

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
        SysUserEntity entity = SysUserConvert.INSTANCE.convert(vo);

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

        if (entity.getStatus() != null && entity.getStatus() == UserStatusEnum.DISABLE.getValue()) {
            sysUserTokenService.forceLogoutByUserId(entity.getId());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long id, Integer status, String reason) {
        if (id == null) {
            throw new ServerException("用户不存在");
        }
        if (status == null || (status != UserStatusEnum.DISABLE.getValue() && status != UserStatusEnum.ENABLED.getValue())) {
            throw new ServerException("状态值无效");
        }
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

        SysUserEntity patch = new SysUserEntity();
        patch.setId(id);
        patch.setStatus(status);
        updateById(patch);

        if (status == UserStatusEnum.DISABLE.getValue()) {
            sysUserTokenService.forceLogoutByUserId(id);
        } else {
            sysUserTokenService.updateCacheAuthByUserId(id);
        }
    }

    @Override
    public void updateLoginInfo(SysUserBaseVO vo) {
        SysUserEntity entity = SysUserConvert.INSTANCE.convert(vo);
        // 设置登录用户ID
        entity.setId(SecurityUser.getUserId());

        // 判断手机号是否存在
        SysUserEntity user = baseMapper.getByMobile(entity.getMobile());
        if (user != null && !user.getId().equals(entity.getId())) {
            throw new ServerException("手机号已经存在");
        }

        // 更新用户
        updateById(entity);

        // 删除用户缓存
        tokenStoreCache.deleteUser(TokenUtils.getAccessToken());
    }

    @Override
    public void updateAvatar(SysUserAvatarVO avatar) {
        SysUserEntity entity = new SysUserEntity();
        entity.setId(SecurityUser.getUserId());
        entity.setAvatar(avatar.getAvatar());
        updateById(entity);

        // 删除用户缓存
        tokenStoreCache.deleteUser(TokenUtils.getAccessToken());
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
    public SysUserVO getByMobile(String mobile) {
        SysUserEntity user = baseMapper.getByMobile(mobile);

        return SysUserConvert.INSTANCE.convert(user);
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

        return new PageResult<>(SysUserConvert.INSTANCE.convertList(list), page.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void importByExcel(MultipartFile file, String password) {
        ExcelUtils.readAnalysis(file, SysUserExcelVO.class, new ExcelFinishCallBack<>() {
            @Override
            public void doSaveBatch(List<SysUserExcelVO> result) {
                ExcelUtils.parseDict(result);
                List<SysUserEntity> userList = SysUserConvert.INSTANCE.convertListEntity(result);
                userList.forEach(user -> user.setPassword(password));
                saveBatch(userList);
            }
        });
    }

    @Override
    @SneakyThrows
    public void export() {
        List<SysUserEntity> list = list(Wrappers.lambdaQuery(SysUserEntity.class).eq(SysUserEntity::getSuperAdmin, SuperAdminEnum.NO.getValue()));
        List<SysUserExcelVO> userExcelVOS = SysUserConvert.INSTANCE.convert2List(list);
        transService.transBatch(userExcelVOS);
        // 写到浏览器打开
        ExcelUtils.excelExport(SysUserExcelVO.class, "用户管理", null, userExcelVOS);
    }

}
