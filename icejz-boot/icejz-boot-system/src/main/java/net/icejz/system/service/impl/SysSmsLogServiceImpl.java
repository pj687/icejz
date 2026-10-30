package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.system.dao.SysSmsLogDao;
import net.icejz.system.entity.SysSmsLogEntity;
import net.icejz.system.query.SysSmsLogQuery;
import net.icejz.system.service.SysSmsLogService;
import net.icejz.system.vo.SysSmsLogVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 短信日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysSmsLogServiceImpl extends BaseServiceImpl<SysSmsLogDao, SysSmsLogEntity> implements SysSmsLogService {

    @Override
    public PageResult<SysSmsLogVO> page(SysSmsLogQuery query) {
        IPage<SysSmsLogEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), SysSmsLogVO.class), page.getTotal());
    }


    private LambdaQueryWrapper<SysSmsLogEntity> getWrapper(SysSmsLogQuery query) {
        LambdaQueryWrapper<SysSmsLogEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(query.getPlatform() != null, SysSmsLogEntity::getPlatform, query.getPlatform());
        wrapper.like(StrUtil.isNotBlank(query.getMobile()), SysSmsLogEntity::getMobile, query.getMobile());
        wrapper.orderByDesc(SysSmsLogEntity::getId);
        return wrapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        removeByIds(idList);
    }

}