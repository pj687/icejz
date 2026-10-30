package net.icejz.framework.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializer;
import tools.jackson.databind.DefaultTyping;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.cfg.DateTimeFeature;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.jsontype.BasicPolymorphicTypeValidator;
import tools.jackson.databind.jsontype.PolymorphicTypeValidator;

/**
 * Redis配置
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Configuration
public class RedisConfig {

    public GenericJacksonJsonRedisSerializer genericJacksonJsonRedisSerializer() {
        PolymorphicTypeValidator ptv = BasicPolymorphicTypeValidator.builder()
                .allowIfBaseType(Object.class)
                .build();

        ObjectMapper objectMapper = JsonMapper.builder()
                .disable(DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS)
                .activateDefaultTyping(ptv, DefaultTyping.NON_FINAL)
                .build();

        return new GenericJacksonJsonRedisSerializer(objectMapper);
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        // Key HashKey使用String序列化
        template.setKeySerializer(RedisSerializer.string());
        template.setHashKeySerializer(RedisSerializer.string());

        // Value HashValue使用Json序列化
        template.setValueSerializer(genericJacksonJsonRedisSerializer());
        template.setHashValueSerializer(genericJacksonJsonRedisSerializer());

        template.setConnectionFactory(factory);

        template.afterPropertiesSet();
        return template;
    }
}
