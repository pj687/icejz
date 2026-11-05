package net.icejz.app.ui.mine

import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import kotlinx.coroutines.launch
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.data.model.DeviceItem
import net.icejz.app.data.model.LoginSecurity
import net.icejz.app.data.model.UserInfo
import net.icejz.app.data.remote.ApiException
import net.icejz.app.data.repository.UserRepository
import net.icejz.app.ui.components.EmptyState
import net.icejz.app.ui.components.IceCard
import net.icejz.app.ui.components.IceField
import net.icejz.app.ui.components.IceNavBar
import net.icejz.app.ui.components.IcePrimaryButton
import net.icejz.app.ui.components.MenuRow
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

@Composable
fun UserInfoScreen(onBack: () -> Unit, onEdit: () -> Unit) {
    val repo = remember { UserRepository() }
    val context = LocalContext.current
    var user by remember { mutableStateOf<UserInfo?>(null) }
    LaunchedEffect(Unit) {
        runCatching { user = repo.info() }
            .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("个人信息", onBack) {
            Text("编辑", color = IceCyan, modifier = Modifier.padding(end = 12.dp).clickable(onClick = onEdit))
        }
        Column(Modifier.padding(18.dp).verticalScroll(rememberScrollState()), horizontalAlignment = Alignment.CenterHorizontally) {
            BoxAvatar(user?.avatar)
            Spacer(Modifier.height(12.dp))
            Text(user?.realName ?: user?.username ?: "-", fontWeight = FontWeight.Bold, fontSize = 20.sp)
            Text("@${user?.username.orEmpty()}", color = IceMute, fontSize = 13.sp)
            Spacer(Modifier.height(16.dp))
            IceCard {
                InfoLine("手机号", user?.mobile ?: "-")
                InfoLine("邮箱", user?.email ?: "-")
                InfoLine("机构", user?.orgName ?: "-")
                InfoLine("性别", when (user?.gender) { 0 -> "男"; 1 -> "女"; else -> "未知" })
            }
        }
    }
}

@Composable
fun UserEditScreen(onBack: () -> Unit) {
    val repo = remember { UserRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var realName by remember { mutableStateOf("") }
    var mobile by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var user by remember { mutableStateOf<UserInfo?>(null) }
    var saving by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        runCatching {
            user = repo.info()
            realName = user?.realName.orEmpty()
            mobile = user?.mobile.orEmpty()
            email = user?.email.orEmpty()
        }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("编辑资料", onBack)
        Column(Modifier.padding(18.dp)) {
            IceField("姓名", realName, "请输入姓名", { realName = it })
            Spacer(Modifier.height(12.dp))
            IceField("手机号", mobile, "请输入手机号", { mobile = it }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone))
            Spacer(Modifier.height(12.dp))
            IceField("邮箱", email, "请输入邮箱", { email = it }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email))
            Spacer(Modifier.height(20.dp))
            IcePrimaryButton("保存", loading = saving) {
                scope.launch {
                    saving = true
                    runCatching {
                        val updated = (user ?: UserInfo()).copy(realName = realName, mobile = mobile, email = email)
                        repo.updateInfo(updated)
                        Toast.makeText(context, "保存成功", Toast.LENGTH_SHORT).show()
                        onBack()
                    }.onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "保存失败", Toast.LENGTH_SHORT).show() }
                    saving = false
                }
            }
        }
    }
}

@Composable
fun PasswordScreen(onBack: () -> Unit) {
    val repo = remember { UserRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var oldPwd by remember { mutableStateOf("") }
    var newPwd by remember { mutableStateOf("") }
    var confirm by remember { mutableStateOf("") }
    var saving by remember { mutableStateOf(false) }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("修改密码", onBack)
        Column(Modifier.padding(18.dp)) {
            IceField("原密码", oldPwd, "请输入原密码", { oldPwd = it }, visualTransformation = PasswordVisualTransformation())
            Spacer(Modifier.height(12.dp))
            IceField("新密码", newPwd, "请输入新密码", { newPwd = it }, visualTransformation = PasswordVisualTransformation())
            Spacer(Modifier.height(12.dp))
            IceField("确认密码", confirm, "请再次输入新密码", { confirm = it }, visualTransformation = PasswordVisualTransformation())
            Spacer(Modifier.height(20.dp))
            IcePrimaryButton("提交", loading = saving) {
                scope.launch {
                    if (newPwd.length < 6) {
                        Toast.makeText(context, "新密码至少 6 位", Toast.LENGTH_SHORT).show(); return@launch
                    }
                    if (newPwd != confirm) {
                        Toast.makeText(context, "两次密码不一致", Toast.LENGTH_SHORT).show(); return@launch
                    }
                    saving = true
                    runCatching {
                        repo.updatePassword(oldPwd, newPwd)
                        Toast.makeText(context, "修改成功", Toast.LENGTH_SHORT).show()
                        onBack()
                    }.onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "修改失败", Toast.LENGTH_SHORT).show() }
                    saving = false
                }
            }
        }
    }
}

@Composable
fun DevicesScreen(onBack: () -> Unit) {
    val repo = remember { UserRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var list by remember { mutableStateOf<List<DeviceItem>>(emptyList()) }
    fun refresh() {
        scope.launch {
            runCatching { list = repo.devices() }
                .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
        }
    }
    LaunchedEffect(Unit) { refresh() }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("登录设备", onBack)
        if (list.isEmpty()) EmptyState("暂无登录设备")
        else Column(Modifier.padding(16.dp).verticalScroll(rememberScrollState())) {
            list.forEach { device ->
                IceCard(Modifier.padding(bottom = 10.dp)) {
                    Text(device.deviceName ?: device.deviceType ?: "设备", fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(4.dp))
                    Text("${device.ip.orEmpty()} · ${device.loginTime.orEmpty()}", color = IceMute, fontSize = 12.sp)
                    if (!device.current && !device.accessToken.isNullOrBlank()) {
                        Spacer(Modifier.height(8.dp))
                        Text(
                            "下线该设备",
                            color = Color(0xFFE11D48),
                            fontSize = 13.sp,
                            modifier = Modifier.clickable {
                                scope.launch {
                                    runCatching {
                                        repo.kickDevice(device.accessToken!!)
                                        Toast.makeText(context, "已下线", Toast.LENGTH_SHORT).show()
                                        refresh()
                                    }.onFailure {
                                        Toast.makeText(context, (it as? ApiException)?.message ?: "操作失败", Toast.LENGTH_SHORT).show()
                                    }
                                }
                            }
                        )
                    } else if (device.current) {
                        Spacer(Modifier.height(6.dp))
                        Text("当前设备", color = IceCyan, fontSize = 12.sp)
                    }
                }
            }
        }
    }
}

@Composable
fun SettingsScreen(
    onBack: () -> Unit,
    onOpenAbout: () -> Unit,
    onOpenDevices: () -> Unit,
    onOpenPassword: () -> Unit
) {
    val repo = remember { UserRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var multi by remember { mutableStateOf(true) }
    LaunchedEffect(Unit) {
        runCatching { multi = repo.loginSecurity().multiDeviceLogin == 1 }
    }
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("设置", onBack)
        IceCard(Modifier.padding(16.dp)) {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("允许多设备登录", fontWeight = FontWeight.Medium)
                    Text("关闭后仅保留最新会话", color = IceMute, fontSize = 12.sp)
                }
                Switch(
                    checked = multi,
                    onCheckedChange = { enabled ->
                        val previous = multi
                        multi = enabled
                        scope.launch {
                            runCatching {
                                repo.saveLoginSecurity(LoginSecurity(if (enabled) 1 else 0))
                                Toast.makeText(context, "已保存", Toast.LENGTH_SHORT).show()
                            }.onFailure {
                                multi = previous
                                Toast.makeText(context, "保存失败", Toast.LENGTH_SHORT).show()
                            }
                        }
                    },
                    colors = SwitchDefaults.colors(checkedTrackColor = IceCyan)
                )
            }
            MenuRow("修改密码") { onOpenPassword() }
            MenuRow("登录设备") { onOpenDevices() }
            MenuRow("关于我们") { onOpenAbout() }
        }
    }
}

@Composable
fun AboutScreen(onBack: () -> Unit) {
    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar("关于我们", onBack)
        Column(
            Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(painterResource(R.drawable.logo), null, Modifier.size(72.dp).clip(RoundedCornerShape(18.dp)))
            Spacer(Modifier.height(12.dp))
            Text(Brand.name, fontWeight = FontWeight.Bold, fontSize = 22.sp)
            Text(Brand.version, color = IceMute, fontSize = 13.sp)
            Spacer(Modifier.height(16.dp))
            Text(Brand.aboutIntro, color = IceMute, fontSize = 14.sp)
            Spacer(Modifier.height(20.dp))
            Brand.features.forEach {
                IceCard(Modifier.padding(bottom = 8.dp)) {
                    Text(it.title, fontWeight = FontWeight.SemiBold)
                    Text(it.desc, color = IceMute, fontSize = 12.sp)
                }
            }
            Spacer(Modifier.height(12.dp))
            Text(Brand.footer, color = IceMute, fontSize = 12.sp)
        }
    }
}

@Composable
private fun BoxAvatar(avatar: String?) {
    androidx.compose.foundation.layout.Box(
        Modifier.size(84.dp).clip(CircleShape).background(IceCyan.copy(0.12f)),
        contentAlignment = Alignment.Center
    ) {
        if (!avatar.isNullOrBlank()) {
            AsyncImage(avatar, null, Modifier.fillMaxSize().clip(CircleShape), contentScale = ContentScale.Crop)
        } else {
            Image(painterResource(R.drawable.logo), null, Modifier.size(52.dp))
        }
    }
}

@Composable
private fun InfoLine(label: String, value: String) {
    Row(Modifier.fillMaxWidth().padding(vertical = 10.dp)) {
        Text(label, color = IceMute, modifier = Modifier.width(72.dp))
        Text(value, color = IceInk)
    }
}
