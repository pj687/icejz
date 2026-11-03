package net.icejz;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * 自定义 Knife4j 文档页与 ICEJZ 主题样式。
 */
@Configuration
public class Knife4jUiConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/icejz-knife4j.css")
                .addResourceLocations("classpath:/static/");
    }

    @RestController
    static class Knife4jDocController {

        @GetMapping(value = "/doc.html", produces = MediaType.TEXT_HTML_VALUE)
        public ResponseEntity<String> docHtml() throws IOException {
            ClassPathResource resource = new ClassPathResource("knife4j-ui/doc.html");
            String html = StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
            return ResponseEntity.ok()
                    .contentType(new MediaType("text", "html", StandardCharsets.UTF_8))
                    .body(html);
        }
    }
}
