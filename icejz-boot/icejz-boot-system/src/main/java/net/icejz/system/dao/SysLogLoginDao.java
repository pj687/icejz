package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysLogLoginEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 登录日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysLogLoginDao extends BaseDao<SysLogLoginEntity> {

}