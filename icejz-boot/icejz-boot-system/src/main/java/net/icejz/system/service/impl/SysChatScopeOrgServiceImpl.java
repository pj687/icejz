package net.icejz.system.service.impl;

import cn.hutool.core.collection.CollUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.system.dao.SysChatScopeOrgDao;
import net.icejz.system.entity.SysChatScopeOrgEntity;
import net.icejz.system.service.SysChatScopeOrgService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SysChatScopeOrgServiceImpl extends BaseServiceImpl<SysChatScopeOrgDao, SysChatScopeOrgEntity>
        implements SysChatScopeOrgService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdate(Long roleId, List<Long> orgIdList) {
        if (orgIdList == null) {
            orgIdList = Collections.emptyList();
        }
        List<Long> dbOrgIdList = getOrgIdList(roleId);
        Collection<Long> insertOrgIdList = CollUtil.subtract(orgIdList, dbOrgIdList);
        if (CollUtil.isNotEmpty(insertOrgIdList)) {
            List<SysChatScopeOrgEntity> list = insertOrgIdList.stream().map(orgId -> {
                SysChatScopeOrgEntity entity = new SysChatScopeOrgEntity();
                entity.setRoleId(roleId);
                entity.setOrgId(orgId);
                return entity;
            }).collect(Collectors.toList());
            saveBatch(list);
        }
        Collection<Long> deleteOrgIdList = CollUtil.subtract(dbOrgIdList, orgIdList);
        if (CollUtil.isNotEmpty(deleteOrgIdList)) {
            remove(new LambdaQueryWrapper<SysChatScopeOrgEntity>()
                    .eq(SysChatScopeOrgEntity::getRoleId, roleId)
                    .in(SysChatScopeOrgEntity::getOrgId, deleteOrgIdList));
        }
    }

    @Override
    public List<Long> getOrgIdList(Long roleId) {
        return baseMapper.getOrgIdList(roleId);
    }

    @Override
    public void deleteByRoleIdList(List<Long> roleIdList) {
        if (CollUtil.isEmpty(roleIdList)) {
            return;
        }
        remove(new LambdaQueryWrapper<SysChatScopeOrgEntity>().in(SysChatScopeOrgEntity::getRoleId, roleIdList));
    }
}
