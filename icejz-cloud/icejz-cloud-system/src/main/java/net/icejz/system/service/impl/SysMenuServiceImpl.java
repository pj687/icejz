package net.icejz.system.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.common.utils.TreeUtils;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.convert.SysMenuConvert;
import net.icejz.system.dao.SysMenuDao;
import net.icejz.system.entity.SysMenuEntity;
import net.icejz.system.enums.MenuClientTypeEnum;
import net.icejz.system.enums.SuperAdminEnum;
import net.icejz.system.service.SysMenuService;
import net.icejz.system.service.SysRoleMenuService;
import net.icejz.system.vo.SysMenuVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 菜单管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysMenuServiceImpl extends BaseServiceImpl<SysMenuDao, SysMenuEntity> implements SysMenuService {
    private final SysRoleMenuService sysRoleMenuService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void save(SysMenuVO vo) {
        SysMenuEntity entity = SysMenuConvert.INSTANCE.convert(vo);
        if (entity.getClientType() == null) {
            entity.setClientType(MenuClientTypeEnum.PC.getValue());
        }

        // 保存菜单
        baseMapper.insert(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update(SysMenuVO vo) {
        SysMenuEntity entity = SysMenuConvert.INSTANCE.convert(vo);
        if (entity.getClientType() == null) {
            entity.setClientType(MenuClientTypeEnum.PC.getValue());
        }

        // 上级菜单不能为自己
        if (entity.getId().equals(entity.getPid())) {
            throw new ServerException("上级菜单不能为自己");
        }

        // 更新菜单
        updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        // 删除菜单
        removeById(id);

        // 删除角色菜单关系
        sysRoleMenuService.deleteByMenuId(id);
    }

    @Override
    public List<SysMenuVO> getMenuList(Integer type, Integer clientType) {
        List<SysMenuEntity> menuList = baseMapper.getMenuList(type, clientType);

        return TreeUtils.build(SysMenuConvert.INSTANCE.convertList(menuList));
    }

    @Override
    public List<SysMenuVO> getUserMenuList(UserDetail user, Integer type, Integer clientType) {
        List<SysMenuEntity> menuList;

        // 系统管理员，拥有最高权限
        if (user.getSuperAdmin().equals(SuperAdminEnum.YES.getValue())) {
            menuList = baseMapper.getMenuList(type, clientType);
        } else {
            menuList = baseMapper.getUserMenuList(user.getId(), type, clientType);
        }

        return TreeUtils.build(SysMenuConvert.INSTANCE.convertList(menuList));
    }

    @Override
    public Long getSubMenuCount(Long pid) {
        return count(new LambdaQueryWrapper<SysMenuEntity>().eq(SysMenuEntity::getPid, pid));
    }

    @Override
    public Set<String> getUserAuthority(UserDetail user) {
        // 系统管理员，拥有最高权限
        List<String> authorityList;
        if (user.getSuperAdmin().equals(SuperAdminEnum.YES.getValue())) {
            authorityList = baseMapper.getAuthorityList();
        } else {
            authorityList = baseMapper.getUserAuthorityList(user.getId());
        }

        // 用户权限列表
        Set<String> permsSet = new HashSet<>();
        for (String authority : authorityList) {
            if (StrUtil.isBlank(authority)) {
                continue;
            }
            permsSet.addAll(Arrays.asList(authority.trim().split(",")));
        }

        return permsSet;
    }

}