package net.icejz.app.util

import java.util.Calendar

fun greetingText(): String {
    val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    return when (hour) {
        in 0..4 -> "夜深了"
        in 5..10 -> "早上好"
        in 11..13 -> "中午好"
        in 14..17 -> "下午好"
        in 18..22 -> "晚上好"
        else -> "你好"
    }
}

fun displayName(realName: String?, username: String?): String =
    realName?.takeIf { it.isNotBlank() } ?: username?.takeIf { it.isNotBlank() } ?: "访客"
