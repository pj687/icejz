package net.icejz.generator.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

/**
 * maku-generator-pro-boot-starter 的 AutoConfiguration 未声明 ComponentScan，
 * 主应用又只扫描 net.icejz，导致 controller/service 未注册、接口 404。
 */
@Configuration
@ComponentScan(
        basePackages = "net.maku.generator",
        excludeFilters = @ComponentScan.Filter(
                type = FilterType.REGEX,
                pattern = "net\\.maku\\.generator\\.autoconfigure\\..*"
        )
)
public class MakuGeneratorScanConfig {
}
