package net.icejz.iot.dao;

import net.icejz.framework.mybatis.dao.BaseDao;
import net.icejz.iot.entity.IotDeviceServiceLogEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 设备服务日志
 *
 * @author LSF icejz_lsf@163.com
 */
@Mapper
public interface IotDeviceServiceLogDao extends BaseDao<IotDeviceServiceLogEntity> {

}