package net.icejz.app.ui.home

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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material3.Icon
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.data.repository.HomeRepository
import net.icejz.app.data.repository.HomeStats
import net.icejz.app.ui.components.IceCard
import net.icejz.app.ui.components.SimpleBarChart
import net.icejz.app.ui.components.Wordmark
import net.icejz.app.ui.navigation.Routes
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.util.displayName
import net.icejz.app.util.greetingText

@Composable
fun HomeScreen(
    authEpoch: Int,
    onNavigate: (String) -> Unit,
    onOpenWorkbench: () -> Unit
) {
    val repo = remember { HomeRepository() }
    var name by remember { mutableStateOf("访客") }
    var unread by remember { mutableIntStateOf(0) }
    var stats by remember { mutableStateOf(HomeStats()) }
    var loading by remember { mutableStateOf(true) }

    LaunchedEffect(authEpoch) {
        loading = true
        runCatching {
            val user = repo.userInfo()
            name = displayName(user.realName, user.username)
            unread = repo.unreadCount()
            stats = repo.fetchHomeStats()
        }
        loading = false
    }

    val dayLabels = listOf("日", "一", "二", "三", "四", "五", "六")
    val weekChart = stats.weekBars.mapIndexed { i, v ->
        val calDay = ((java.util.Calendar.getInstance().get(java.util.Calendar.DAY_OF_WEEK) - 1 - (6 - i) + 70) % 7)
        dayLabels[calDay] to v
    }

    Box(Modifier.fillMaxSize()) {
        Column(
            Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .statusBarsPadding()
                .padding(bottom = 24.dp)
        ) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.verticalGradient(listOf(Color(0xFFDDF3FC), Color(0xFFF3F6FA)))
                    )
                    .padding(horizontal = 18.dp, vertical = 14.dp)
            ) {
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Image(painterResource(R.drawable.logo), null, Modifier.size(36.dp).clip(CircleShape))
                    Spacer(Modifier.width(10.dp))
                    Column(Modifier.weight(1f)) {
                        Text("ICEJZ", fontWeight = FontWeight.Bold, color = IceInk)
                        Text(Brand.tagline, color = IceMute, fontSize = 11.sp)
                    }
                    Box(Modifier.clickable { onNavigate(Routes.Message) }) {
                        Icon(Icons.Outlined.Notifications, null, tint = IceInk)
                        if (unread > 0) {
                            Box(
                                Modifier
                                    .align(Alignment.TopEnd)
                                    .size(8.dp)
                                    .clip(CircleShape)
                                    .background(Color(0xFFE11D48))
                            )
                        }
                    }
                }
                Spacer(Modifier.height(18.dp))
                Text("${greetingText()}，$name", color = IceMute, fontSize = 14.sp)
                Spacer(Modifier.height(4.dp))
                Wordmark(36, 36)
                Spacer(Modifier.height(6.dp))
                Text(Brand.homeLine, color = IceMute, fontSize = 13.sp)
                Spacer(Modifier.height(14.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    ActionCard("进入工作台", "系统管理入口", Modifier.weight(1f), true, onOpenWorkbench)
                    ActionCard(
                        "消息",
                        if (unread > 0) "$unread 未读" else "暂无未读",
                        Modifier.weight(1f),
                        false
                    ) { onNavigate(Routes.Message) }
                }
            }

            Spacer(Modifier.height(12.dp))
            Row(
                Modifier.padding(horizontal = 18.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                listOf(
                    Triple("用户", stats.userTotal, Routes.SysUser),
                    Triple("机构", stats.orgTotal, Routes.SysOrg),
                    Triple("角色", stats.roleTotal, Routes.SysRole),
                    Triple("未读", stats.msgUnread, Routes.Message)
                ).forEach { (lab, value, route) ->
                    IceCard(
                        Modifier
                            .weight(1f)
                            .clickable { onNavigate(route) }
                    ) {
                        Text(lab, color = IceMute, fontSize = 12.sp)
                        Spacer(Modifier.height(6.dp))
                        Text(if (loading) "—" else "$value", color = IceInk, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(Modifier.height(12.dp))
            IceCard(Modifier.padding(horizontal = 18.dp)) {
                Text("快捷入口", fontWeight = FontWeight.SemiBold, color = IceInk)
                Spacer(Modifier.height(12.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    listOf(
                        "用户" to Routes.SysUser,
                        "机构" to Routes.SysOrg,
                        "角色" to Routes.SysRole,
                        "消息" to Routes.Message
                    ).forEach { (label, route) ->
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            modifier = Modifier.clickable { onNavigate(route) }
                        ) {
                            Box(
                                Modifier
                                    .size(46.dp)
                                    .clip(CircleShape)
                                    .background(IceCyan.copy(0.12f)),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(label.take(1), color = IceCyan, fontWeight = FontWeight.Bold)
                            }
                            Spacer(Modifier.height(6.dp))
                            Text(label, fontSize = 12.sp, color = IceInk)
                        }
                    }
                }
            }

            if (!loading && (stats.userTotal + stats.orgTotal + stats.msgTotal) > 0) {
                Spacer(Modifier.height(12.dp))
                IceCard(Modifier.padding(horizontal = 18.dp)) {
                    Text("资源总览", fontWeight = FontWeight.SemiBold)
                    Text("管理端同源", color = IceMute, fontSize = 12.sp)
                    Spacer(Modifier.height(8.dp))
                    SimpleBarChart(
                        listOf(
                            "用户" to stats.userTotal,
                            "机构" to stats.orgTotal,
                            "角色" to stats.roleTotal,
                            "消息" to stats.msgTotal
                        )
                    )
                }
                Spacer(Modifier.height(12.dp))
                IceCard(Modifier.padding(horizontal = 18.dp)) {
                    Text("近 7 日消息", fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(8.dp))
                    SimpleBarChart(weekChart)
                }
                Spacer(Modifier.height(12.dp))
                IceCard(Modifier.padding(horizontal = 18.dp)) {
                    Text("消息已读率", fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(8.dp))
                    Text("${stats.readPercent}%", color = IceCyan, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                    Text("已读 ${stats.msgRead} · 未读 ${stats.msgUnread}", color = IceMute, fontSize = 12.sp)
                }
            }

            Spacer(Modifier.height(12.dp))
            IceCard(Modifier.padding(horizontal = 18.dp)) {
                Text("平台能力", fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(10.dp))
                Brand.features.forEachIndexed { index, feature ->
                    Row(Modifier.padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            String.format("%02d", index + 1),
                            color = IceCyan,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.width(32.dp)
                        )
                        Column {
                            Text(feature.title, fontWeight = FontWeight.SemiBold, color = IceInk)
                            Text(feature.desc, color = IceMute, fontSize = 12.sp)
                        }
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
            Text(Brand.footer, color = IceMute, fontSize = 12.sp, modifier = Modifier.align(Alignment.CenterHorizontally))
        }

        Column(
            Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 18.dp, bottom = 18.dp)
                .clickable { onNavigate(Routes.Assistant) },
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                Modifier
                    .size(62.dp)
                    .clip(CircleShape)
                    .background(Color.White)
                    .padding(8.dp),
                contentAlignment = Alignment.Center
            ) {
                Image(painterResource(R.drawable.xiaobing_main), null, Modifier.size(48.dp))
            }
            Spacer(Modifier.height(4.dp))
            Text(
                "小冰助手",
                modifier = Modifier
                    .clip(RoundedCornerShape(999.dp))
                    .background(Color.White)
                    .padding(horizontal = 8.dp, vertical = 2.dp),
                fontSize = 11.sp,
                color = IceCyan,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun ActionCard(
    title: String,
    desc: String,
    modifier: Modifier,
    primary: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier
            .clip(RoundedCornerShape(16.dp))
            .background(if (primary) IceCyan else Color.White.copy(0.9f))
            .clickable(onClick = onClick)
            .padding(14.dp)
    ) {
        Text(title, color = if (primary) Color.White else IceInk, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(4.dp))
        Text(desc, color = if (primary) Color.White.copy(0.85f) else IceMute, fontSize = 12.sp)
    }
}
