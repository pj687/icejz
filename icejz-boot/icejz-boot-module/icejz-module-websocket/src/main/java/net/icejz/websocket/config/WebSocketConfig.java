package net.icejz.websocket.config;

import lombok.AllArgsConstructor;
import net.icejz.websocket.handler.MessageWebSocketHandler;
import net.icejz.websocket.handler.UserHandshakeInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;


/**
 * WebSocket配置
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Configuration
@EnableWebSocket
@AllArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {
    private final MessageWebSocketHandler handler;
    private final UserHandshakeInterceptor interceptor;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(handler, "/ws")
                .addInterceptors(interceptor).setAllowedOriginPatterns("*");
    }
}
