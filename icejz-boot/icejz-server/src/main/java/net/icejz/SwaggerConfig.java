package net.icejz;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger配置
 *
 * @author ice_jz
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public GroupedOpenApi systemApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz.system"};
        return GroupedOpenApi.builder()
                .group("1")
                .displayName("System API")
                .pathsToMatch(paths)
                .packagesToScan(packagedToMatch).build();
    }

    @Bean
    public GroupedOpenApi quartzApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz.quartz"};
        return GroupedOpenApi.builder()
                .group("2")
                .displayName("Quartz API")
                .pathsToMatch(paths)
                .packagesToScan(packagedToMatch).build();
    }

    @Bean
    public GroupedOpenApi monitorApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz.monitor"};
        return GroupedOpenApi.builder()
                .group("3")
                .displayName("Monitor API")
                .pathsToMatch(paths)
                .packagesToScan(packagedToMatch).build();
    }

    @Bean
    public GroupedOpenApi memberApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz.member"};
        return GroupedOpenApi.builder()
                .group("4")
                .displayName("Member API")
                .pathsToMatch(paths)
                .packagesToScan(packagedToMatch).build();
    }

    @Bean
    public GroupedOpenApi iotApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz.iot"};
        return GroupedOpenApi.builder()
                .group("5")
                .displayName("Iot API")
                .pathsToMatch(paths)
                .packagesToScan(packagedToMatch).build();
    }

    @Bean
    public GroupedOpenApi otherApi() {
        String[] paths = {"/**"};
        String[] packagedToMatch = {"net.icejz"};
        return GroupedOpenApi.builder()
                .group("99")
                .displayName("Other API")
                .pathsToMatch(paths)
                .packagesToExclude(
                        "net.icejz.system", "net.icejz.quartz", "net.icejz.monitor", "net.icejz.member", "net.icejz.iot",
                        "net.maku.generator"
                )
                .packagesToScan(packagedToMatch)
                .build();
    }

    @Bean
    public OpenAPI openApi() {
        Contact contact = new Contact();
        contact.setName("ice_jz");
        contact.setEmail("960681673@qq.com");

        return new OpenAPI().info(new Info()
                .title("ICEJZ API")
                .description("ICEJZ API")
                .contact(contact)
                .version("5.x")
                .termsOfService("https://icejz.net")
        );
    }

}