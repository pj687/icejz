package net.icejz.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import net.icejz.framework.common.utils.Result;
import net.icejz.framework.operatelog.annotations.OperateLog;
import net.icejz.framework.operatelog.enums.OperateTypeEnum;
import net.icejz.framework.security.user.SecurityUser;
import net.icejz.framework.security.user.UserDetail;
import net.icejz.system.convert.SysMenuConvert;
import net.icejz.system.entity.SysMenuEntity;
import net.icejz.system.enums.MenuClientTypeEnum;
import net.icejz.system.enums.MenuTypeEnum;
import net.icejz.system.service.SysMenuService;
import net.icejz.system.vo.SysMenuVO;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

/**
 * 菜单管理
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@RestController
@RequestMapping("sys/menu")
@Tag(name = "菜单管理")
@AllArgsConstructor
public class SysMenuController {
    private final SysMenuService sysMenuService;

    @GetMapping("nav")
    @Operation(summary = "菜单导航")
    @Parameter(name = "clientType", description = "客户端 0：PC  1：APP  2：小程序，默认 PC")
    public Result<List<SysMenuVO>> nav(
            @RequestParam(value = "clientType", required = false) Integer clientType) {
        UserDetail user = SecurityUser.getUser();
        int client = clientType == null ? MenuClientTypeEnum.PC.getValue() : clientType;
        List<SysMenuVO> list = sysMenuService.getUserMenuList(user, MenuTypeEnum.MENU.getValue(), client);

        return Result.ok(list);
    }

    @GetMapping("authority")
    @Operation(summary = "用户权限标识")
    public Result<Set<String>> authority() {
        UserDetail user = SecurityUser.getUser();
        Set<String> set = sysMenuService.getUserAuthority(user);

        return Result.ok(set);
    }

    @GetMapping("list")
    @Operation(summary = "菜单列表")
    @Parameter(name = "type", description = "菜单类型 0：菜单 1：按钮  2：接口  null：全部")
    @Parameter(name = "clientType", description = "客户端 0：PC  1：APP  2：小程序  null：全部")
    @PreAuthorize("hasAuthority('sys:menu:list')")
    public Result<List<SysMenuVO>> list(Integer type, Integer clientType) {
        List<SysMenuVO> list = sysMenuService.getMenuList(type, clientType);

        return Result.ok(list);
    }

    @GetMapping("{id}")
    @Operation(summary = "信息")
    @PreAuthorize("hasAuthority('sys:menu:info')")
    public Result<SysMenuVO> get(@PathVariable("id") Long id) {
        SysMenuEntity entity = sysMenuService.getById(id);
        SysMenuVO vo = SysMenuConvert.INSTANCE.convert(entity);

        // 获取上级菜单名称
        if (entity.getPid() != null) {
            SysMenuEntity parentEntity = sysMenuService.getById(entity.getPid());
            vo.setParentName(parentEntity.getName());
        }

        return Result.ok(vo);
    }

    @PostMapping
    @Operation(summary = "保存")
    @OperateLog(type = OperateTypeEnum.INSERT)
    @PreAuthorize("hasAuthority('sys:menu:save')")
    public Result<String> save(@RequestBody @Valid SysMenuVO vo) {
        sysMenuService.save(vo);

        return Result.ok();
    }

    @PutMapping
    @Operation(summary = "修改")
    @OperateLog(type = OperateTypeEnum.UPDATE)
    @PreAuthorize("hasAuthority('sys:menu:update')")
    public Result<String> update(@RequestBody @Valid SysMenuVO vo) {
        sysMenuService.update(vo);

        return Result.ok();
    }

    @DeleteMapping("{id}")
    @Operation(summary = "删除")
    @OperateLog(type = OperateTypeEnum.DELETE)
    @PreAuthorize("hasAuthority('sys:menu:delete')")
    public Result<String> delete(@PathVariable("id") Long id) {
        // 判断是否有子菜单或按钮
        Long count = sysMenuService.getSubMenuCount(id);
        if (count > 0) {
            return Result.error("请先删除子菜单");
        }

        sysMenuService.delete(id);

        return Result.ok();
    }
}