package net.icejz.iot.communication.mqtt.handler;


import net.icejz.iot.communication.dto.DeviceCommandResponseDTO;

/**
 * 设备命令响应处理器
 *
 * @author LSF icejz_lsf@163.com
 */
public interface DeviceCommandResponseHandler {
    /**
     * 设备命令响应处理
     *
     * @param topic
     * @param commandResponse
     */
    void handle(String topic, DeviceCommandResponseDTO commandResponse);
}
