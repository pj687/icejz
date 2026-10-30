package net.icejz.system.controller;

import cn.hutool.core.bean.BeanUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.entity.SysAiModelEntity;
import net.icejz.system.query.SysAiModelQuery;
import net.icejz.system.service.SysAiModelService;
import net.icejz.system.vo.SysAiChatResultVO;
import net.icejz.system.vo.SysAiChatVO;
import net.icejz.system.vo.SysAiModelVO;
import net.icejz.system.vo.SysAiRobotVO;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("sys/ai")
@Tag(name = "AI助手")
@AllArgsConstructor
public class SysAiModelController {
    private final SysAiModelService sysAiModelService;

    @GetMapping("model/page")
    @Operation(summary = "模型分页")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<PageResult<SysAiModelVO>> page(@ParameterObject @Valid SysAiModelQuery query) {
        return Result.ok(sysAiModelService.page(query));
    }

    @GetMapping("model/list")
    @Operation(summary = "模型列表")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<List<SysAiModelVO>> list() {
        return Result.ok(sysAiModelService.listAll());
    }

    @GetMapping("model/enabled")
    @Operation(summary = "启用模型列表")
    public Result<List<SysAiModelVO>> enabled() {
        return Result.ok(sysAiModelService.listEnabled());
    }

    @GetMapping("model/{id}")
    @Operation(summary = "模型信息")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<SysAiModelVO> get(@PathVariable("id") Long id) {
        SysAiModelEntity entity = sysAiModelService.getById(id);
        return Result.ok(BeanUtil.copyProperties(entity, SysAiModelVO.class));
    }

    @PostMapping("model")
    @Operation(summary = "保存模型")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<String> save(@RequestBody SysAiModelVO vo) {
        sysAiModelService.save(vo);
        return Result.ok();
    }

    @PutMapping("model")
    @Operation(summary = "修改模型")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<String> update(@RequestBody @Valid SysAiModelVO vo) {
        sysAiModelService.update(vo);
        return Result.ok();
    }

    @DeleteMapping("model")
    @Operation(summary = "删除模型")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<String> delete(@RequestBody List<Long> idList) {
        sysAiModelService.delete(idList);
        return Result.ok();
    }

    @PostMapping("model/test/{id}")
    @Operation(summary = "测试模型")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    @OperateLog(type = OperateTypeEnum.OTHER)
    public Result<Map<String, String>> test(@PathVariable("id") Long id) {
        String content = sysAiModelService.testModel(id);
        Map<String, String> map = new HashMap<>(2);
        map.put("content", content);
        return Result.ok(map);
    }

    @GetMapping("robot/info")
    @Operation(summary = "机器人信息")
    public Result<SysAiRobotVO> robotInfo() {
        return Result.ok(sysAiModelService.getRobotInfo());
    }

    @PutMapping("robot")
    @Operation(summary = "保存机器人设置")
    @PreAuthorize("hasAuthority('sys:ai:config')")
    public Result<String> saveRobot(@RequestBody SysAiRobotVO vo) {
        sysAiModelService.saveRobot(vo);
        return Result.ok();
    }

    @PostMapping("chat")
    @Operation(summary = "对话")
    @OperateLog(type = OperateTypeEnum.OTHER)
    public Result<SysAiChatResultVO> chat(@RequestBody SysAiChatVO vo) {
        return Result.ok(sysAiModelService.chat(vo));
    }
}
