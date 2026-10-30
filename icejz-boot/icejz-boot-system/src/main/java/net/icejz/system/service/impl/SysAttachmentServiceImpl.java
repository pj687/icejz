package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.system.dao.SysAttachmentDao;
import net.icejz.system.entity.SysAttachmentEntity;
import net.icejz.system.query.SysAttachmentQuery;
import net.icejz.system.service.SysAttachmentService;
import net.icejz.system.vo.SysAttachmentVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 附件管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Service
@AllArgsConstructor
public class SysAttachmentServiceImpl extends BaseServiceImpl<SysAttachmentDao, SysAttachmentEntity> implements SysAttachmentService {

    @Override
    public PageResult<SysAttachmentVO> page(SysAttachmentQuery query) {
        IPage<SysAttachmentEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), SysAttachmentVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<SysAttachmentEntity> getWrapper(SysAttachmentQuery query) {
        LambdaQueryWrapper<SysAttachmentEntity> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(StrUtil.isNotBlank(query.getPlatform()), SysAttachmentEntity::getPlatform, query.getPlatform());
        wrapper.like(StrUtil.isNotBlank(query.getName()), SysAttachmentEntity::getName, query.getName());
        wrapper.orderByDesc(SysAttachmentEntity::getId);
        return wrapper;
    }

    @Override
    public void save(SysAttachmentVO vo) {
        SysAttachmentEntity entity = BeanUtil.copyProperties(vo, SysAttachmentEntity.class);

        baseMapper.insert(entity);
    }

    @Override
    public void update(SysAttachmentVO vo) {
        SysAttachmentEntity entity = BeanUtil.copyProperties(vo, SysAttachmentEntity.class);

        updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        removeByIds(idList);
    }

}