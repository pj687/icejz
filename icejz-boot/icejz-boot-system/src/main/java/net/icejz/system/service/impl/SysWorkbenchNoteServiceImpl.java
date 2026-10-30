package net.icejz.system.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.system.dao.SysWorkbenchNoteDao;
import net.icejz.system.entity.SysWorkbenchNoteEntity;
import net.icejz.system.service.SysWorkbenchNoteService;
import net.icejz.system.vo.SysWorkbenchNoteVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 工作台日历记事
 */
@Service
@AllArgsConstructor
public class SysWorkbenchNoteServiceImpl extends BaseServiceImpl<SysWorkbenchNoteDao, SysWorkbenchNoteEntity>
        implements SysWorkbenchNoteService {

    @Override
    public List<SysWorkbenchNoteVO> listMine(String yearMonth) {
        Long userId = SecurityUser.getUserId();
        LambdaQueryWrapper<SysWorkbenchNoteEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysWorkbenchNoteEntity::getUserId, userId);
        if (StrUtil.isNotBlank(yearMonth) && yearMonth.length() >= 7) {
            wrapper.likeRight(SysWorkbenchNoteEntity::getNoteDate, yearMonth.substring(0, 7));
        }
        wrapper.orderByDesc(SysWorkbenchNoteEntity::getCreateTime);
        return BeanUtil.copyToList(baseMapper.selectList(wrapper), SysWorkbenchNoteVO.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysWorkbenchNoteVO saveMine(SysWorkbenchNoteVO vo) {
        Long userId = SecurityUser.getUserId();
        SysWorkbenchNoteEntity entity = BeanUtil.copyProperties(vo, SysWorkbenchNoteEntity.class);
        entity.setId(null);
        entity.setUserId(userId);
        if (StrUtil.isBlank(entity.getNoteType())) {
            entity.setNoteType("memo");
        }
        if (StrUtil.isBlank(entity.getContent()) || StrUtil.isBlank(entity.getNoteDate())) {
            throw new ServerException("记事日期与内容不能为空");
        }
        if (entity.getContent().length() > 1000) {
            throw new ServerException("记事内容过长");
        }
        baseMapper.insert(entity);
        return BeanUtil.copyProperties(entity, SysWorkbenchNoteVO.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMine(List<Long> idList) {
        if (idList == null || idList.isEmpty()) {
            return;
        }
        Long userId = SecurityUser.getUserId();
        LambdaQueryWrapper<SysWorkbenchNoteEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysWorkbenchNoteEntity::getUserId, userId);
        wrapper.in(SysWorkbenchNoteEntity::getId, idList);
        baseMapper.delete(wrapper);
    }
}
