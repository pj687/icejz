package net.icejz.iot.communication.mqtt.handler;

import cn.hutool.core.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.icejz.framework.common.utils.JsonUtils;
import net.icejz.iot.communication.service.MQTTService;
import net.icejz.iot.communication.dto.DeviceCommandResponseDTO;
import net.icejz.iot.communication.mqtt.factory.DeviceCommandResponseHandlerFactory;
import net.icejz.iot.enums.DeviceTopicEnum;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * 设备命令响应处理器
 *
 * @author LSF icejz_lsf@163.com
 */
@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "spring.mqtt", name = "enabled", havingValue = "true", matchIfMissing = true)
public class DeviceCommandResponseMqttMessageHandler implements MqttMessageHandler {

    private final DeviceCommandResponseHandlerFactory deviceCommandResponseHandlerFactory;

    private final MQTTService deviceMqttService;

    @Override
    public boolean supports(String topic) {
        return DeviceTopicEnum.startsWith(topic, DeviceTopicEnum.COMMAND_RESPONSE.getTopic());
    }

    @Override
    public void handle(String topic, String message) {
        DeviceCommandResponseDTO commandResponseDTO = parseCommandReplyMessage(topic, message);
        Optional.ofNullable(commandResponseDTO.getCommand())
                .orElseThrow(() -> new IllegalArgumentException(StrUtil.format("缺失指令类型! 主题:'{}',消息:{}", topic, message)));
        Optional.ofNullable(commandResponseDTO.getCommandId())
                .orElseThrow(() -> new IllegalArgumentException(StrUtil.format("缺失指令ID! 主题:'{}',消息:{}", topic, message)));

        Optional.ofNullable(commandResponseDTO)
                .ifPresent(responseDTO -> {
                    // 调用设备命令执行器的命令响应处理逻辑
                    try {
                        deviceMqttService.commandReplied( responseDTO);
                    } catch (Exception e) {
                        log.error(StrUtil.format("调用设备命令执行器响应处理方法出错，topic:{}, message:{}", topic, message), e);
                    }
                    // 调用自定义命令响应处理器
                    try {
                        deviceCommandResponseHandlerFactory.getHandlers().forEach(h -> h.handle(topic, responseDTO));
                    } catch (Exception e) {
                        log.error(StrUtil.format("调用设备命令响应响应处理器出错，topic:{}, message:{}", topic, message), e);
                    }
                });
    }

    private DeviceCommandResponseDTO parseCommandReplyMessage(String topic, String message) {
        try {
            DeviceCommandResponseDTO commandResponse = JsonUtils.parseObject(message, DeviceCommandResponseDTO.class);
            if (StrUtil.isBlank(commandResponse.getCommandId())) {
                log.error(StrUtil.format("主题'{}'的消息,缺失指令ID", topic));
                return null;
            }
            return commandResponse;

        } catch (Exception e) {
            log.error(StrUtil.format("将主题'{}'的消息解析为设备命令响应对象失败", topic), e);
            return null;
        }
    }
}