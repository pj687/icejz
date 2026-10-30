package net.icejz.websocket.handler;

import net.icejz.framework.security.user.SecurityUser;
import net.icejz.websocket.util.SessionUserUtil;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;


/**
 * webSocket 握手拦截器
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Component
public class UserHandshakeInterceptor implements HandshakeInterceptor {

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        // 当前连接的用户
        SessionUserUtil.setUser(SecurityUser.getUser(), attributes);

        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Exception exception) {

    }
}
