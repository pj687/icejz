package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.enums.CaptchaTypeEnum;
import net.icejz.system.service.SysCaptchaConfigService;
import net.icejz.system.vo.SysCaptchaConfigVO;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

/**
 * 分端验证码类型配置
 */
@RestController
@RequestMapping("sys/captcha/config")
@Tag(name = "验证码配置")
@AllArgsConstructor
public class SysCaptchaConfigController {
    private final SysCaptchaConfigService sysCaptchaConfigService;

    @GetMapping
    @Operation(summary = "获取分端验证码配置")
    @PreAuthorize("hasAuthority('sys:captcha:config')")
    public Result<SysCaptchaConfigVO> get() {
        SysCaptchaConfigVO vo = sysCaptchaConfigService.getConfig();
        List<SysCaptchaConfigVO.CaptchaTypeOption> options = new ArrayList<>();
        options.add(opt(CaptchaTypeEnum.SPEC, "字母数字"));
        options.add(opt(CaptchaTypeEnum.NUMBER, "纯数字"));
        options.add(opt(CaptchaTypeEnum.CHINESE, "汉字"));
        options.add(opt(CaptchaTypeEnum.ARITHMETIC, "算术"));
        options.add(opt(CaptchaTypeEnum.PATTERN, "点选图案"));
        options.add(opt(CaptchaTypeEnum.BLOCK_PUZZLE, "滑动拼图"));
        options.add(opt(CaptchaTypeEnum.CLICK_WORD, "文字点选"));
        options.add(opt(CaptchaTypeEnum.POW, "算力校验 PoW"));
        options.add(opt(CaptchaTypeEnum.TURNSTILE, "Cloudflare Turnstile"));
        vo.setTypeOptions(options);
        vo.setMobileType(vo.getSmsType());
        return Result.ok(vo);
    }

    @PutMapping
    @Operation(summary = "保存分端验证码配置")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:captcha:config')")
    public Result<String> save(@RequestBody SysCaptchaConfigVO vo) {
        if (vo.getSmsType() == null && vo.getMobileType() != null) {
            vo.setSmsType(vo.getMobileType());
        }
        sysCaptchaConfigService.saveConfig(vo);
        return Result.ok();
    }

    private SysCaptchaConfigVO.CaptchaTypeOption opt(CaptchaTypeEnum type, String label) {
        return new SysCaptchaConfigVO.CaptchaTypeOption(type.getCode(), type.getMode(), type.getTip(), label);
    }
}
