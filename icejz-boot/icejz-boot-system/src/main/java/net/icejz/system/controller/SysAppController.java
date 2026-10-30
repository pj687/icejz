package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.system.vo.SysAppVersionVO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 平台应用信息
 */
@RestController
@RequestMapping("sys/app")
@Tag(name = "平台信息")
@RequiredArgsConstructor
public class SysAppController {

    @Value("${icejz.name:ICEJZ}")
    private String name;

    @Value("${icejz.version:1.0.1}")
    private String version;

    @Value("${spring.application.name:icejz-boot}")
    private String application;

    @GetMapping("version")
    @Operation(summary = "平台版本号")
    public Result<SysAppVersionVO> version() {
        SysAppVersionVO vo = new SysAppVersionVO();
        vo.setName(name);
        vo.setVersion(version);
        vo.setApplication(application);
        return Result.ok(vo);
    }
}
