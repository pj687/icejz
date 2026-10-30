package net.icejz.iot.communication.mqtt.handler;


import net.icejz.iot.communication.dto.DevicePropertyDTO;

/**
 * 设备属性变化处理器
 *
 * @author LSF icejz_lsf@163.com
 */
public interface DevicePropertyChangeHandler {
    /**
     * 设备属性状态变化处理
     *
     * @param topic
     * @param deviceStatus
     */
    void handle(String topic, DevicePropertyDTO deviceStatus);
}
