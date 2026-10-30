package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 首页 欢迎信息
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Tag(name = "首页")
@RestController
public class IndexController {

    @GetMapping("/")
    public String index() {
        return "您好，项目已启动，祝您使用愉快！";
    }
}
