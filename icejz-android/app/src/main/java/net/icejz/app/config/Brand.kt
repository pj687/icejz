package net.icejz.app.config

object Brand {
    const val name = "ICEJZ"
    const val fullName = "ICEJZ 低代码开发平台"
    const val slogan = "更快交付 · 更稳运行 · 更易扩展"
    const val tagline = "低代码开发平台 · ICECORE 引擎"
    const val description =
        "面向企业的低代码开发平台，支持代码生成、在线表单、工作流与多端接入，帮助团队更快交付业务系统。"
    const val poweredBy = "ICEJZ"
    const val footer = "© 2026 ICEJZ"
    const val version = "v1.0.3"
    const val workspaceKicker = "ICEJZ WORKSPACE"
    const val workspaceTitle = "工作台"
    const val workspaceSub = "与管理端同源数据，移动端快速查阅"
    const val homeLine = "代码生成 · 在线表单 · 工作流 · 多端接入"
    const val loginHint = "进入 ICEJZ 移动端"
    const val aboutIntro =
        "ICEJZ 是面向企业的低代码开发平台，基于 ICECORE 引擎提供代码生成、在线表单、工作流与多端接入能力，帮助团队更快交付业务系统。"

    data class Feature(val title: String, val desc: String)

    val features = listOf(
        Feature("安全可靠", "统一认证、细粒度权限与操作审计"),
        Feature("快速开发", "代码生成与模块化能力加速交付"),
        Feature("灵活扩展", "业务模块可插拔，适配多端场景"),
        Feature("支持信创", "面向国产化环境持续适配")
    )
}
