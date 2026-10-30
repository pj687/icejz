package net.icejz.iot.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.iot.entity.IotDeviceEventLogEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 设备事件日志
 *
 * @author LSF icejz_lsf@163.com
 */
@Mapper
public interface IotDeviceEventLogDao extends BaseDao<IotDeviceEventLogEntity> {

}