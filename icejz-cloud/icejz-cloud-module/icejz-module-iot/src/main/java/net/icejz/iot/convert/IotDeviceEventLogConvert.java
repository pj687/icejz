package net.icejz.iot.convert;

import net.icejz.iot.entity.IotDeviceEventLogEntity;
import net.icejz.iot.vo.IotDeviceEventLogVO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 设备事件日志
 *
 * @author LSF icejz_lsf@163.com
 */
@Mapper
public interface IotDeviceEventLogConvert {
    IotDeviceEventLogConvert INSTANCE = Mappers.getMapper(IotDeviceEventLogConvert.class);

    IotDeviceEventLogEntity convert(IotDeviceEventLogVO vo);

    IotDeviceEventLogVO convert(IotDeviceEventLogEntity entity);

    List<IotDeviceEventLogVO> convertList(List<IotDeviceEventLogEntity> list);

}