package net.icejz.member.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.member.entity.MemberUserEntity;
import net.icejz.member.query.MemberUserQuery;
import net.icejz.member.vo.MemberUserVO;
import net.icejz.member.dao.MemberUserDao;
import net.icejz.member.service.MemberUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 会员管理
 *
 * @author ice_jz
 * @since 1.0.0 2024-03-11
 */
@Service
@AllArgsConstructor
public class MemberUserServiceImpl extends BaseServiceImpl<MemberUserDao, MemberUserEntity> implements MemberUserService {

    @Override
    public PageResult<MemberUserVO> page(MemberUserQuery query) {
        IPage<MemberUserEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));

        return new PageResult<>(BeanUtil.copyToList(page.getRecords(), MemberUserVO.class), page.getTotal());
    }

    private LambdaQueryWrapper<MemberUserEntity> getWrapper(MemberUserQuery query){
        LambdaQueryWrapper<MemberUserEntity> wrapper = Wrappers.lambdaQuery();

        return wrapper;
    }

    @Override
    public void save(MemberUserVO vo) {
        MemberUserEntity entity = BeanUtil.copyProperties(vo, MemberUserEntity.class);

        baseMapper.insert(entity);
    }

    @Override
    public void update(MemberUserVO vo) {
        MemberUserEntity entity = BeanUtil.copyProperties(vo, MemberUserEntity.class);

        updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        removeByIds(idList);
    }

}