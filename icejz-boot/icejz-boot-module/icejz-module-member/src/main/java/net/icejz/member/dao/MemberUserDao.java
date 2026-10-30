package net.icejz.member.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.member.entity.MemberUserEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 会员管理
 *
 * @author ice_jz
 */
@Mapper
public interface MemberUserDao extends BaseDao<MemberUserEntity> {

}