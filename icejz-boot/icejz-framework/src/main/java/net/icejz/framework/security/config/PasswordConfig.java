package net.icejz.framework.security.config;

import net.icejz.framework.security.crypto.Sm3PasswordEncoder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 加密配置
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Configuration
public class PasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        // 使用国密SM3加密
        return new Sm3PasswordEncoder();

        // return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }
}
