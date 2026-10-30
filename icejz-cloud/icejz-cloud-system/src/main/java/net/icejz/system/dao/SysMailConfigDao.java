package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysMailConfigEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 邮件配置
 *
 * @author ice_jz
 */
@Mapper
public interface SysMailConfigDao extends BaseDao<SysMailConfigEntity> {

}