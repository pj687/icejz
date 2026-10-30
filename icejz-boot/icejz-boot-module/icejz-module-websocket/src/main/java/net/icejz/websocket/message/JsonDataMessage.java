package net.icejz.websocket.message;

import lombok.Data;

/**
 * websocket json 消息
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public class JsonDataMessage<T> {
    /**
     * 消息类型 预留
     */
    private String type = "default";
    /**
     * 消息数据
     */
    private T data;

}
