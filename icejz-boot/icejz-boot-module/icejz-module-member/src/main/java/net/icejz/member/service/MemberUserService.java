package net.icejz.member.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.member.entity.MemberUserEntity;
import net.icejz.member.query.MemberUserQuery;
import net.icejz.member.vo.MemberUserVO;

import java.util.List;

/**
 * 会员管理
 *
 * @author ice_jz
 */
public interface MemberUserService extends BaseService<MemberUserEntity> {

    PageResult<MemberUserVO> page(MemberUserQuery query);

    void save(MemberUserVO vo);

    void update(MemberUserVO vo);

    void delete(List<Long> idList);
}