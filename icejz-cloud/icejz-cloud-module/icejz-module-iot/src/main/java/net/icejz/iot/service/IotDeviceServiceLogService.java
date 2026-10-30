package net.icejz.iot.service;

import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.BaseService;
import net.icejz.iot.entity.IotDeviceServiceLogEntity;
import net.icejz.iot.enums.DeviceCommandEnum;
import net.icejz.iot.query.IotDeviceServiceLogQuery;
import net.icejz.iot.vo.IotDeviceServiceLogVO;

import java.util.List;

/**
 * 设备服务日志
 *
 * @author LSF icejz_lsf@163.com
 */
public interface IotDeviceServiceLogService extends BaseService<IotDeviceServiceLogEntity> {

    PageResult<IotDeviceServiceLogVO> page(IotDeviceServiceLogQuery query);

    void save(IotDeviceServiceLogVO vo);

    void update(IotDeviceServiceLogVO vo);

    void delete(List<Long> idList);

    /**
     * 创建设备服务日志
     *
     * @param deviceId 设备ID
     * @param tenantId 租户ID
     * @param command  服务类型
     * @param eventUid 事件UID
     * @param payload  事件数据
     * @return 设备事件
     */
    IotDeviceServiceLogEntity createDeviceServiceLog(Long deviceId, Long tenantId, DeviceCommandEnum command,
                                                     String eventUid, Object payload);

    /**
     * 创建设备服务日志并保存
     *
     * @param deviceId 设备ID
     * @param tenantId 租户ID
     * @param command  服务类型
     * @param eventUid 事件UID
     * @param payload  事件数据
     * @return 设备事件
     */
    void createAndSaveDeviceServiceLog(Long deviceId, Long tenantId, DeviceCommandEnum command,
                                       String eventUid, Object payload);
}