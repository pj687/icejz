package net.icejz.member.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import net.icejz.framework.common.utils.PageResult;
import net.icejz.framework.common.utils.Result;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户端门户接口（与管理端登录态互通）。
 * 业务表尚未落地时先返回空数据，保证小程序/App 可正常联调认证与消息。
 */
@RestController
@RequestMapping("member")
@Tag(name = "用户端门户")
public class MemberPortalController {

    @GetMapping("service-item/list")
    @Operation(summary = "服务项目列表")
    public Result<List<Map<String, Object>>> serviceItemList(@RequestParam(required = false) String category) {
        return Result.ok(Collections.emptyList());
    }

    @GetMapping("service-item/{id}")
    @Operation(summary = "服务项目详情")
    public Result<Map<String, Object>> serviceItemDetail(@PathVariable Long id) {
        return Result.ok(Collections.emptyMap());
    }

    @GetMapping("booking/page")
    @Operation(summary = "预约分页")
    public Result<PageResult<Map<String, Object>>> bookingPage() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("booking/{id}")
    @Operation(summary = "预约详情")
    public Result<Map<String, Object>> bookingDetail(@PathVariable Long id) {
        return Result.ok(Collections.emptyMap());
    }

    @PostMapping("booking")
    @Operation(summary = "创建预约")
    public Result<String> bookingCreate(@RequestBody Map<String, Object> body) {
        return Result.error("预约服务尚未开通，请联系管理员");
    }

    @PutMapping("booking/{id}/status/{status}")
    @Operation(summary = "更新预约状态")
    public Result<String> bookingStatus(@PathVariable Long id, @PathVariable Integer status, @RequestBody(required = false) Map<String, Object> body) {
        return Result.error("预约服务尚未开通，请联系管理员");
    }

    @GetMapping("order/page")
    @Operation(summary = "订单分页")
    public Result<PageResult<Map<String, Object>>> orderPage() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("order/{id}")
    @Operation(summary = "订单详情")
    public Result<Map<String, Object>> orderDetail(@PathVariable Long id) {
        return Result.ok(Collections.emptyMap());
    }

    @PutMapping("order/{id}/review")
    @Operation(summary = "订单评价")
    public Result<String> orderReview(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        return Result.error("订单服务尚未开通，请联系管理员");
    }

    @GetMapping("activity/page")
    @Operation(summary = "活动分页")
    public Result<PageResult<Map<String, Object>>> activityPage() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("activity/{id}")
    @Operation(summary = "活动详情")
    public Result<Map<String, Object>> activityDetail(@PathVariable Long id) {
        return Result.ok(Collections.emptyMap());
    }

    @PostMapping("activity-signup/signup")
    @Operation(summary = "活动报名")
    public Result<String> activitySignup(@RequestBody Map<String, Object> body) {
        return Result.error("活动报名尚未开通，请联系管理员");
    }

    @GetMapping("activity-signup/my/page")
    @Operation(summary = "我的活动报名")
    public Result<PageResult<Map<String, Object>>> myActivitySignup() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @PostMapping("activity-review/submit")
    @Operation(summary = "提交活动评价")
    public Result<String> activityReviewSubmit(@RequestBody Map<String, Object> body) {
        return Result.error("活动评价尚未开通，请联系管理员");
    }

    @GetMapping("activity-review/page")
    @Operation(summary = "活动评价分页")
    public Result<PageResult<Map<String, Object>>> activityReviewPage() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("activity-review/my/page")
    @Operation(summary = "我的活动评价")
    public Result<PageResult<Map<String, Object>>> myActivityReview() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("activity-review/stats/{activityId}")
    @Operation(summary = "活动评价统计")
    public Result<Map<String, Object>> activityReviewStats(@PathVariable Long activityId) {
        Map<String, Object> stats = new HashMap<>(4);
        stats.put("avgScore", 0);
        stats.put("total", 0);
        return Result.ok(stats);
    }

    @GetMapping("health-record/summary")
    @Operation(summary = "健康概览")
    public Result<Map<String, Object>> healthSummary(@RequestParam(required = false) Long elderUserId) {
        return Result.ok(Collections.emptyMap());
    }

    @GetMapping("health-record/trend")
    @Operation(summary = "健康趋势")
    public Result<List<Map<String, Object>>> healthTrend(@RequestParam String recordType,
                                                         @RequestParam(defaultValue = "30") Integer limit,
                                                         @RequestParam(required = false) Long elderUserId) {
        return Result.ok(Collections.emptyList());
    }

    @PostMapping("health-record")
    @Operation(summary = "新增健康记录")
    public Result<String> healthRecordAdd(@RequestBody Map<String, Object> body) {
        return Result.error("健康监测尚未开通，请联系管理员");
    }

    @GetMapping("health-alert/my")
    @Operation(summary = "我的健康预警")
    public Result<PageResult<Map<String, Object>>> healthAlertMy() {
        return Result.ok(new PageResult<>(Collections.emptyList(), 0));
    }

    @GetMapping("elder-archive")
    @Operation(summary = "老人档案")
    public Result<Map<String, Object>> elderArchiveGet() {
        return Result.ok(Collections.emptyMap());
    }

    @PostMapping("elder-archive")
    @Operation(summary = "新建老人档案")
    public Result<String> elderArchiveCreate(@RequestBody Map<String, Object> body) {
        return Result.error("老人档案尚未开通，请联系管理员");
    }

    @PutMapping("elder-archive")
    @Operation(summary = "更新老人档案")
    public Result<String> elderArchiveUpdate(@RequestBody Map<String, Object> body) {
        return Result.error("老人档案尚未开通，请联系管理员");
    }

    @PutMapping("family-binding/remark")
    @Operation(summary = "更新绑定备注")
    public Result<String> familyBindingRemark(@RequestBody Map<String, Object> body) {
        return Result.error("家属绑定尚未开通，请联系管理员");
    }

    @DeleteMapping("family-binding/unbind")
    @Operation(summary = "解除绑定")
    public Result<String> familyBindingUnbind(@RequestBody Map<String, Object> body) {
        return Result.error("家属绑定尚未开通，请联系管理员");
    }

    @PostMapping("family-binding/invite")
    @Operation(summary = "邀请家属")
    public Result<String> familyBindingInvite(@RequestBody Map<String, Object> body) {
        return Result.error("家属绑定尚未开通，请联系管理员");
    }

    @PostMapping("family-binding/confirm")
    @Operation(summary = "确认绑定")
    public Result<String> familyBindingConfirm(@RequestBody Map<String, Object> body) {
        return Result.error("家属绑定尚未开通，请联系管理员");
    }
}
