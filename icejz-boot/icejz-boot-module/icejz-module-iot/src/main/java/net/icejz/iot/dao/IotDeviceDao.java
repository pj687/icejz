package net.icejz.iot.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.iot.entity.IotDeviceEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 设备表
 *
 * @author LSF icejz_lsf@163.com
 */
@Mapper
public interface IotDeviceDao extends BaseDao<IotDeviceEntity> {

}