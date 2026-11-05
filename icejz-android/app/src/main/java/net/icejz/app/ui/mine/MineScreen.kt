package net.icejz.app.ui.mine

import android.widget.Toast
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
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import kotlinx.coroutines.launch
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.data.repository.AuthRepository
import net.icejz.app.data.repository.HomeRepository
import net.icejz.app.ui.components.IceCard
import net.icejz.app.ui.components.MenuRow
import net.icejz.app.ui.components.Wordmark
import net.icejz.app.ui.navigation.Routes
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.util.displayName
import net.icejz.app.util.greetingText

@Composable
fun MineScreen(
    authEpoch: Int,
    onNavigate: (String) -> Unit,
    onLogout: () -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val homeRepo = remember { HomeRepository() }
    val authRepo = remember { AuthRepository() }

    var name by remember { mutableStateOf("访客") }
    var username by remember { mutableStateOf("") }
    var avatar by remember { mutableStateOf<String?>(null) }
    var orgName by remember { mutableStateOf("") }
    var unread by remember { mutableIntStateOf(0) }
    var userTotal by remember { mutableIntStateOf(0) }
    var orgTotal by remember { mutableIntStateOf(0) }
    var roleTotal by remember { mutableIntStateOf(0) }

    LaunchedEffect(authEpoch) {
        runCatching {
            val user = homeRepo.userInfo()
            name = displayName(user.realName, user.username)
            username = user.username.orEmpty()
            avatar = user.avatar
            orgName = user.orgName.orEmpty()
            unread = homeRepo.unreadCount()
            val stats = homeRepo.fetchHomeStats()
            userTotal = stats.userTotal
            orgTotal = stats.orgTotal
            roleTotal = stats.roleTotal
        }
    }

    Column(
        Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .background(Brush.verticalGradient(listOf(Color(0xFFE8F5FC), Color(0xFFF3F6FA))))
            .statusBarsPadding()
            .padding(bottom = 28.dp)
    ) {
        Column(Modifier.padding(horizontal = 18.dp, vertical = 12.dp)) {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Wordmark(18, 18)
                    Text("账号中心", color = IceMute, fontSize = 12.sp)
                }
                Icon(
                    Icons.Outlined.Notifications, null, tint = IceInk,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .clickable { onNavigate(Routes.Message) }
                        .padding(8.dp)
                )
                Spacer(Modifier.width(8.dp))
                Icon(
                    Icons.Outlined.Settings, null, tint = IceInk,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .clickable { onNavigate(Routes.Settings) }
                        .padding(8.dp)
                )
            }
            Spacer(Modifier.height(16.dp))
            IceCard {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier
                            .size(64.dp)
                            .clip(CircleShape)
                            .background(IceCyan.copy(0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        if (!avatar.isNullOrBlank()) {
                            AsyncImage(avatar, null, Modifier.fillMaxSize().clip(CircleShape), contentScale = ContentScale.Crop)
                        } else {
                            Image(painterResource(R.drawable.logo), null, Modifier.size(40.dp))
                        }
                    }
                    Spacer(Modifier.width(12.dp))
                    Column(Modifier.weight(1f)) {
                        Text(greetingText(), color = IceMute, fontSize = 12.sp)
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(name, fontWeight = FontWeight.Bold, fontSize = 20.sp, color = IceInk)
                            Spacer(Modifier.width(8.dp))
                            Text(
                                "成员",
                                modifier = Modifier
                                    .clip(RoundedCornerShape(999.dp))
                                    .background(IceCyan.copy(0.12f))
                                    .padding(horizontal = 8.dp, vertical = 2.dp),
                                color = IceCyan,
                                fontSize = 11.sp
                            )
                        }
                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            if (username.isNotBlank()) {
                                Text("@$username", color = IceMute, fontSize = 12.sp)
                            }
                            Text(orgName.ifBlank { "未绑定机构" }, color = IceMute, fontSize = 12.sp)
                        }
                    }
                    Text(
                        "编辑",
                        color = IceCyan,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.clickable { onNavigate(Routes.UserInfo) }
                    )
                }
                Spacer(Modifier.height(16.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    listOf(
                        "$userTotal" to "用户",
                        "$orgTotal" to "机构",
                        "$roleTotal" to "角色",
                        "$unread" to "未读"
                    ).forEach { (v, l) ->
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(v, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                            Text(l, color = IceMute, fontSize = 12.sp)
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        IceCard(Modifier.padding(horizontal = 18.dp)) {
            Text("常用功能", fontWeight = FontWeight.SemiBold)
            Text("系统管理快捷入口", color = IceMute, fontSize = 12.sp)
            Spacer(Modifier.height(4.dp))
            MenuRow("我的消息", if (unread > 0) "$unread 未读" else "站内通知") { onNavigate(Routes.Message) }
            MenuRow("用户管理", "账号查阅") { onNavigate(Routes.SysUser) }
            MenuRow("机构管理", "组织架构") { onNavigate(Routes.SysOrg) }
            MenuRow("角色管理", "权限编码") { onNavigate(Routes.SysRole) }
            MenuRow("小冰助手", "智能问答") { onNavigate(Routes.Assistant) }
        }

        Spacer(Modifier.height(12.dp))
        IceCard(Modifier.padding(horizontal = 18.dp)) {
            Text("账号与安全", fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(4.dp))
            MenuRow("个人信息", "资料与头像") { onNavigate(Routes.UserInfo) }
            MenuRow("修改密码", "账号安全") { onNavigate(Routes.Password) }
            MenuRow("登录设备", "会话管理") { onNavigate(Routes.Devices) }
            MenuRow("设置", "偏好与关于") { onNavigate(Routes.Settings) }
            MenuRow("关于我们", Brand.version) { onNavigate(Routes.About) }
        }

        Spacer(Modifier.height(18.dp))
        Box(
            Modifier
                .padding(horizontal = 18.dp)
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Color.White)
                .clickable {
                    scope.launch {
                        authRepo.logout()
                        Toast.makeText(context, "已退出登录", Toast.LENGTH_SHORT).show()
                        onLogout()
                    }
                }
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            Text("退出登录", color = Color(0xFFE11D48), fontWeight = FontWeight.SemiBold)
        }
        Spacer(Modifier.height(12.dp))
        Text(Brand.footer, color = IceMute, fontSize = 12.sp, modifier = Modifier.align(Alignment.CenterHorizontally))
    }
}
