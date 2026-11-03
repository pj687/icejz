package net.icejz.iot.communication.service;

import lombok.RequiredArgsConstructor;
import net.icejz.framework.common.exception.ServerException;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

/**
 * 设备协议服务工厂
 *
 * @author LSF icejz_lsf@163.com
 */
@Service
@RequiredArgsConstructor
public class CommunicationServiceFactory {

    private final ObjectProvider<MQTTService> mqttService;
    private final TCPService tcpService;

    public BaseCommunication getProtocol(String protocolType) {
        if (protocolType == null) {
            throw new ServerException("协议不存在！");
        }
        switch (protocolType) {
            case "MQTT":
                MQTTService mqtt = mqttService.getIfAvailable();
                if (mqtt == null) {
                    throw new ServerException("MQTT 未启用，请在配置中设置 spring.mqtt.enabled=true");
                }
                return mqtt;
            case "TCP":
                return tcpService;
            default:
                return null;
        }
    }
}
