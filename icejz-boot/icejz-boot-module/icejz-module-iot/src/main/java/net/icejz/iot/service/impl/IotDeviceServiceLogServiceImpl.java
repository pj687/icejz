package net.icejz.iot.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.JsonUtils;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.mybatis.service.impl.BaseServiceImpl;
import net.icejz.iot.dao.IotDeviceServiceLogDao;
import net.icejz.iot.entity.IotDeviceServiceLogEntity;
import net.icejz.iot.enums.DeviceCommandEnum;
import net.icejz.iot.query.IotDeviceServiceLogQuery;
import net.icejz.iot.service.IotDeviceServiceLogService;
import net.icejz.iot.vo.IotDeviceServiceLogVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 设备服务日志
 *
 * @author LSF icejz_lsf@163.com
 */
@Service
@AllArgsConstructor
public class IotDeviceServiceLogServiceImpl extends BaseServiceImpl<IotDeviceServiceLogDao, IotDeviceServiceLogEntity> implements IotDeviceServiceLogService {

    @Override
    public PageResult<IotDeviceServiceLogVO> page(IotDeviceServiceLogQuery query) {
        IPage<IotDeviceServiceLogEntity> page = baseMapper.selectPage(getPage(query), getWrapper(query));
        List<IotDeviceServiceLogVO> vos = BeanUtil.copyToList(page.getRecords(), IotDeviceServiceLogVO.class);
        vos.forEach(vo -> {
            vo.setDeviceCommandEnum(DeviceCommandEnum.getEnum(vo.getServiceType()));
        });
        return new PageResult<>(vos, page.getTotal());
    }

    private LambdaQueryWrapper<IotDeviceServiceLogEntity> getWrapper(IotDeviceServiceLogQuery query) {
        LambdaQueryWrapper<IotDeviceServiceLogEntity> wrapper = Wrappers.lambdaQuery();
        if (StrUtil.isNotBlank(query.getDeviceCommandEnum())) {
            wrapper.eq(IotDeviceServiceLogEntity::getServiceType, DeviceCommandEnum.parse(query.getDeviceCommandEnum()).getValue());
        }
        wrapper.eq(query.getDeviceId() != null, IotDeviceServiceLogEntity::getDeviceId, query.getDeviceId());
        wrapper.orderByDesc(IotDeviceServiceLogEntity::getServiceTime);
        return wrapper;
    }

    @Override
    public void save(IotDeviceServiceLogVO vo) {
        IotDeviceServiceLogEntity entity = BeanUtil.copyProperties(vo, IotDeviceServiceLogEntity.class);

        baseMapper.insert(entity);
    }

    @Override
    public void update(IotDeviceServiceLogVO vo) {
        IotDeviceServiceLogEntity entity = BeanUtil.copyProperties(vo, IotDeviceServiceLogEntity.class);

        updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(List<Long> idList) {
        removeByIds(idList);
    }

    @Override
    public IotDeviceServiceLogEntity createDeviceServiceLog(Long deviceId, Long tenantId, DeviceCommandEnum serviceCommand, String eventUid, Object payload) {
        IotDeviceServiceLogEntity deviceServiceLog = new IotDeviceServiceLogEntity();
        deviceServiceLog.setDeviceId(deviceId);
        deviceServiceLog.setTenantId(tenantId);
        deviceServiceLog.setServiceType(serviceCommand.getValue());
        deviceServiceLog.setServiceUid(eventUid);
        if (payload != null) {
            deviceServiceLog.setServicePayload((payload instanceof String)
                    ? (String) payload
                    : JsonUtils.toJsonString(payload));
        }
        deviceServiceLog.setServiceTime(LocalDateTime.now());
        return deviceServiceLog;
    }

    @Override
    public void createAndSaveDeviceServiceLog(Long deviceId, Long tenantId, DeviceCommandEnum serviceCommand, String eventUid, Object payload) {
        save(createDeviceServiceLog(deviceId, tenantId, serviceCommand, eventUid, payload));
    }

}