package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysLogOperateEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 操作日志
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Mapper
public interface SysLogOperateDao extends BaseDao<SysLogOperateEntity> {

}