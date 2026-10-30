package net.icejz.framework.common.xss;

import cn.hutool.core.util.StrUtil;
import tools.jackson.core.JacksonException;
import tools.jackson.core.JsonParser;
import tools.jackson.databind.DeserializationContext;
import tools.jackson.databind.ValueDeserializer;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.HttpContextUtils;
import org.springframework.util.PathMatcher;

/**
 * xss json过滤
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@AllArgsConstructor
public class XssFilterJsonDeserializer extends ValueDeserializer<String> {
    private final XssProperties properties;
    private final PathMatcher pathMatcher;

    @Override
    public String deserialize(JsonParser jsonParser, DeserializationContext deserializationContext) throws JacksonException {
        String value = jsonParser.getValueAsString();
        if (StrUtil.isBlank(value)) {
            return value;
        }

        HttpServletRequest request = HttpContextUtils.getHttpServletRequest();
        if (request == null) {
            return value;
        }

        // 判断该URI是否放行
        boolean flag = properties.getExcludeUrls().stream().anyMatch(excludeUrl -> pathMatcher.match(excludeUrl, request.getServletPath()));
        if (flag) {
            return value;
        }

        return XssUtils.filter(value);
    }

    @Override
    public Class<String> handledType() {
        return String.class;
    }
}
