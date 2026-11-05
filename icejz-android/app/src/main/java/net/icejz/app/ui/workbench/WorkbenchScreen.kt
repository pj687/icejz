package net.icejz.app.ui.workbench

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import net.icejz.app.R
import net.icejz.app.data.repository.HomeRepository
import net.icejz.app.ui.components.IceCard
import net.icejz.app.ui.components.Wordmark
import net.icejz.app.ui.navigation.Routes
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.util.displayName
import net.icejz.app.util.greetingText
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

@Composable
fun WorkbenchScreen(authEpoch: Int, onNavigate: (String) -> Unit) {
    val repo = remember { HomeRepository() }
    var name by remember { mutableStateOf("访客") }
    var username by remember { mutableStateOf("") }
    var avatar by remember { mutableStateOf<String?>(null) }
    var orgName by remember { mutableStateOf("未绑定机构") }
    var unread by remember { mutableIntStateOf(0) }
    var viewCal by remember { mutableStateOf(Calendar.getInstance()) }
    var selectedDay by remember { mutableIntStateOf(Calendar.getInstance().get(Calendar.DAY_OF_MONTH)) }

    LaunchedEffect(authEpoch) {
        runCatching {
            val user = repo.userInfo()
            name = displayName(user.realName, user.username)
            username = user.username.orEmpty()
            avatar = user.avatar
            orgName = user.orgName?.ifBlank { "未绑定机构" } ?: "未绑定机构"
            unread = repo.unreadCount()
        }
    }

    val today = Calendar.getInstance()
    val weekDay = SimpleDateFormat("EEEE", Locale.CHINA).format(Date())
    val todayLabel = SimpleDateFormat("M月d日", Locale.CHINA).format(Date())

    val projects = listOf(
        Triple("用户权限梳理", "角色菜单授权复核", 72) to Routes.SysRole,
        Triple("消息中心巡检", "未读通知与推送核对", 45) to Routes.Message,
        Triple("组织架构对齐", "机构树与人员归属核对", 58) to Routes.SysOrg
    )

    Column(
        Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .statusBarsPadding()
            .padding(bottom = 24.dp)
    ) {
        Column(Modifier.padding(horizontal = 18.dp, vertical = 12.dp)) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(22.dp))
                    .background(
                        Brush.linearGradient(listOf(Color(0xFF0F1B2D), Color(0xFF16324A), Color(0xFF0C5F84)))
                    )
                    .clickable { onNavigate(Routes.UserInfo) }
                    .padding(16.dp)
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Wordmark(16, 16)
                        Text(" / WORKSPACE", color = Color.White.copy(0.7f), fontSize = 12.sp)
                    }
                    Spacer(Modifier.height(14.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            Modifier
                                .size(54.dp)
                                .clip(CircleShape)
                                .background(Color.White.copy(0.15f)),
                            contentAlignment = Alignment.Center
                        ) {
                            if (!avatar.isNullOrBlank()) {
                                AsyncImage(avatar, null, Modifier.fillMaxSize().clip(CircleShape), contentScale = ContentScale.Crop)
                            } else {
                                Image(painterResource(R.drawable.logo), null, Modifier.size(34.dp))
                            }
                        }
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(greetingText(), color = Color.White.copy(0.7f), fontSize = 12.sp)
                            Text(name, color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                            Text(orgName, color = Color.White.copy(0.65f), fontSize = 12.sp)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(weekDay, color = Color.White.copy(0.7f), fontSize = 12.sp)
                            Text(todayLabel, color = Color.White, fontWeight = FontWeight.SemiBold)
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(
                            if (username.isNotBlank()) "@$username" else "今天也保持高效推进",
                            color = Color.White.copy(0.7f),
                            fontSize = 12.sp
                        )
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(Modifier.size(6.dp).clip(CircleShape).background(Color(0xFF34D399)))
                            Spacer(Modifier.width(6.dp))
                            Text("在岗", color = Color.White, fontSize = 12.sp)
                        }
                    }
                }
            }
        }

        Row(
            Modifier.padding(horizontal = 18.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            listOf("进行中" to "3", "待办" to "4", "消息" to "$unread", "记事" to "0").forEach { (lab, value) ->
                IceCard(Modifier.weight(1f)) {
                    Text(lab, color = IceMute, fontSize = 11.sp)
                    Spacer(Modifier.height(4.dp))
                    Text(value, color = IceInk, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(Modifier.height(12.dp))
        IceCard(
            Modifier
                .padding(horizontal = 18.dp)
                .clickable { onNavigate(Routes.Assistant) }
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Image(painterResource(R.drawable.xiaobing_head), null, Modifier.size(40.dp))
                Spacer(Modifier.width(10.dp))
                Column(Modifier.weight(1f)) {
                    Text("智能建议", fontWeight = FontWeight.SemiBold)
                    Text("可让小冰帮你整理今日待办", color = IceMute, fontSize = 12.sp)
                }
                Text("问问小冰", color = IceCyan, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
            }
        }

        Spacer(Modifier.height(12.dp))
        IceCard(Modifier.padding(horizontal = 18.dp)) {
            Text("快捷入口", fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(12.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                listOf(
                    "用户" to Routes.SysUser,
                    "消息" to Routes.Message,
                    "小冰" to Routes.Assistant,
                    "资料" to Routes.UserInfo
                ).forEach { (label, route) ->
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.clickable { onNavigate(route) }
                    ) {
                        Box(
                            Modifier.size(44.dp).clip(CircleShape).background(IceCyan.copy(0.12f)),
                            contentAlignment = Alignment.Center
                        ) { Text(label.take(1), color = IceCyan, fontWeight = FontWeight.Bold) }
                        Spacer(Modifier.height(6.dp))
                        Text(label, fontSize = 12.sp)
                    }
                }
            }
        }

        Spacer(Modifier.height(12.dp))
        IceCard(Modifier.padding(horizontal = 18.dp)) {
            Text("进行中的事项", fontWeight = FontWeight.SemiBold)
            Text("按优先级推进今日关键交付", color = IceMute, fontSize = 12.sp)
            Spacer(Modifier.height(10.dp))
            projects.forEach { (info, route) ->
                val (title, desc, percent) = info
                Column(Modifier.padding(vertical = 8.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text(title, fontWeight = FontWeight.SemiBold)
                            Text(desc, color = IceMute, fontSize = 12.sp)
                        }
                        Text(
                            "进入",
                            color = IceCyan,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.clickable { onNavigate(route) }
                        )
                    }
                    Spacer(Modifier.height(8.dp))
                    LinearProgressIndicator(
                        progress = { percent / 100f },
                        modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(99.dp)),
                        color = IceCyan,
                        trackColor = Color(0xFFE8EEF5)
                    )
                }
            }
        }

        Spacer(Modifier.height(12.dp))
        IceCard(Modifier.padding(horizontal = 18.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Column {
                    Text("${viewCal.get(Calendar.YEAR)}", color = IceMute, fontSize = 12.sp)
                    Text("${viewCal.get(Calendar.MONTH) + 1}月", fontWeight = FontWeight.Bold, fontSize = 20.sp)
                }
                Row {
                    Text("‹", modifier = Modifier.clickable {
                        viewCal = (viewCal.clone() as Calendar).apply { add(Calendar.MONTH, -1) }
                    }.padding(8.dp), fontSize = 20.sp)
                    Text("本月", modifier = Modifier.clickable {
                        viewCal = Calendar.getInstance()
                        selectedDay = today.get(Calendar.DAY_OF_MONTH)
                    }.padding(8.dp), color = IceCyan)
                    Text("›", modifier = Modifier.clickable {
                        viewCal = (viewCal.clone() as Calendar).apply { add(Calendar.MONTH, 1) }
                    }.padding(8.dp), fontSize = 20.sp)
                }
            }
            Spacer(Modifier.height(8.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                listOf("日", "一", "二", "三", "四", "五", "六").forEach {
                    Text(it, modifier = Modifier.width(36.dp), color = IceMute, fontSize = 12.sp)
                }
            }
            Spacer(Modifier.height(6.dp))
            CalendarGrid(viewCal, selectedDay, today) { selectedDay = it }
            Spacer(Modifier.height(10.dp))
            Text(
                "${viewCal.get(Calendar.MONTH) + 1}月${selectedDay}日 · 暂无记事",
                color = IceMute,
                fontSize = 13.sp
            )
        }
    }
}

@Composable
private fun CalendarGrid(
    viewCal: Calendar,
    selectedDay: Int,
    today: Calendar,
    onSelect: (Int) -> Unit
) {
    val cal = viewCal.clone() as Calendar
    cal.set(Calendar.DAY_OF_MONTH, 1)
    val firstWeekday = (cal.get(Calendar.DAY_OF_WEEK) + 5) % 7
    val maxDay = cal.getActualMaximum(Calendar.DAY_OF_MONTH)
    val cells = buildList {
        repeat(firstWeekday) { add(null) }
        for (d in 1..maxDay) add(d)
    }
    Column {
        cells.chunked(7).forEach { week ->
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                week.forEach { day ->
                    val isToday = day != null &&
                        viewCal.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                        viewCal.get(Calendar.MONTH) == today.get(Calendar.MONTH) &&
                        day == today.get(Calendar.DAY_OF_MONTH)
                    val selected = day == selectedDay
                    Box(
                        Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    selected -> IceCyan
                                    isToday -> IceCyan.copy(0.15f)
                                    else -> Color.Transparent
                                }
                            )
                            .then(if (day != null) Modifier.clickable { onSelect(day) } else Modifier),
                        contentAlignment = Alignment.Center
                    ) {
                        if (day != null) {
                            Text(
                                "$day",
                                color = when {
                                    selected -> Color.White
                                    isToday -> IceCyan
                                    else -> IceInk
                                },
                                fontSize = 13.sp
                            )
                        }
                    }
                }
                repeat(7 - week.size) { Spacer(Modifier.size(36.dp)) }
            }
        }
    }
}
