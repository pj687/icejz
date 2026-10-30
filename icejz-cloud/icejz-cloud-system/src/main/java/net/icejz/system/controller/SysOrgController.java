package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.system.convert.SysOrgConvert;
import net.icejz.system.entity.SysOrgEntity;
import net.icejz.system.service.SysOrgService;
import net.icejz.system.vo.SysOrgVO;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 机构管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@RestController
@RequestMapping("sys/org")
@Tag(name = "机构管理")
@AllArgsConstructor
public class SysOrgController {
    private final SysOrgService sysOrgService;

    @GetMapping("list")
    @Operation(summary = "列表")
    @PreAuthorize("hasAuthority('sys:org:list')")
    public Result<List<SysOrgVO>> list() {
        List<SysOrgVO> list = sysOrgService.getList();

        return Result.ok(list);
    }

    @GetMapping("{id}")
    @Operation(summary = "信息")
    @PreAuthorize("hasAuthority('sys:org:info')")
    public Result<SysOrgVO> get(@PathVariable("id") Long id) {
        SysOrgEntity entity = sysOrgService.getById(id);
        SysOrgVO vo = SysOrgConvert.INSTANCE.convert(entity);

        // 获取上级机构名称
        if (entity.getPid() != null) {
            SysOrgEntity parentEntity = sysOrgService.getById(entity.getPid());
            vo.setParentName(parentEntity.getName());
        }

        return Result.ok(vo);
    }

    @PostMapping
    @Operation(summary = "保存")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:org:save')")
    public Result<String> save(@RequestBody @Valid SysOrgVO vo) {
        sysOrgService.save(vo);

        return Result.ok();
    }

    @PutMapping
    @Operation(summary = "修改")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:org:update')")
    public Result<String> update(@RequestBody @Valid SysOrgVO vo) {
        sysOrgService.update(vo);

        return Result.ok();
    }

    @DeleteMapping("{id}")
    @Operation(summary = "删除")
    @OperateLog(type = OperateTypeEnum.DELETE)
    @PreAuthorize("hasAuthority('sys:org:delete')")
    public Result<String> delete(@PathVariable("id") Long id) {
        sysOrgService.delete(id);

        return Result.ok();
    }

    @PostMapping("nameList")
    @Operation(summary = "名称列表")
    public Result<List<String>> nameList(@RequestBody List<Long> idList) {
        List<String> list = sysOrgService.getNameList(idList);

        return Result.ok(list);
    }

}