package net.icejz.system.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.system.entity.SysMessageEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 站内消息
 */
@Mapper
public interface SysMessageDao extends BaseDao<SysMessageEntity> {
}
