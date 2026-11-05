package net.icejz.app.ui.login

import android.graphics.BitmapFactory
import android.util.Base64
import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.data.model.CompleteProfileRequest
import net.icejz.app.data.model.TokenData
import net.icejz.app.data.remote.ApiException
import net.icejz.app.data.repository.AuthRepository
import net.icejz.app.ui.components.IceField
import net.icejz.app.ui.components.IcePrimaryButton
import net.icejz.app.ui.components.Wordmark
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.util.Sm2Util

@Composable
fun LoginScreen(onLoggedIn: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val repo = remember { AuthRepository() }

    var mode by remember { mutableStateOf("account") }
    var agreed by remember { mutableStateOf(false) }
    var logging by remember { mutableStateOf(false) }
    var captchaEnabled by remember { mutableStateOf(true) }
    var captchaKey by remember { mutableStateOf("") }
    var captchaValue by remember { mutableStateOf("") }
    var captchaImage by remember { mutableStateOf<String?>(null) }
    var captchaTip by remember { mutableStateOf("") }

    var username by remember { mutableStateOf("admin") }
    var password by remember { mutableStateOf("123456") }
    var mobile by remember { mutableStateOf("") }
    var smsCode by remember { mutableStateOf("") }
    var smsLeft by remember { mutableIntStateOf(0) }

    var showComplete by remember { mutableStateOf(false) }
    var pending by remember { mutableStateOf<TokenData?>(null) }
    var realName by remember { mutableStateOf("") }
    var roleId by remember { mutableStateOf<Long?>(null) }
    var gender by remember { mutableIntStateOf(2) }
    var completing by remember { mutableStateOf(false) }

    fun toast(msg: String) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
    }

    suspend fun loadCaptcha() {
        runCatching {
            val channel = if (mode == "mobile") "sms" else "app"
            val data = repo.loadCaptcha(channel)
            captchaKey = data.key.orEmpty()
            captchaImage = data.image
            captchaTip = data.tip.orEmpty()
            captchaValue = ""
        }.onFailure {
            toast((it as? ApiException)?.message ?: "验证码加载失败")
        }
    }

    LaunchedEffect(Unit) {
        captchaEnabled = runCatching { repo.captchaEnabled() }.getOrDefault(true)
        if (!showComplete) loadCaptcha()
    }
    LaunchedEffect(mode) {
        if (!showComplete) loadCaptcha()
    }
    LaunchedEffect(smsLeft) {
        if (smsLeft > 0) {
            delay(1000)
            smsLeft -= 1
        }
    }

    fun ensureAgreement(): Boolean {
        if (!agreed) {
            toast("请先同意用户协议与隐私政策")
            return false
        }
        return true
    }

    fun handleSuccess(token: TokenData) {
        scope.launch {
            runCatching {
                repo.persistLogin(token)
                toast("登录成功")
                delay(600)
                onLoggedIn()
            }.onFailure {
                toast(it.message ?: "登录失败")
            }
        }
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(listOf(Color(0xFFEEF6FB), Color(0xFFF3F6FA)))
            )
            .statusBarsPadding()
            .navigationBarsPadding()
    ) {
        Column(
            Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 18.dp, vertical = 12.dp)
        ) {
            Spacer(Modifier.height(24.dp))
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                Box(
                    Modifier
                        .size(78.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(2.dp, Color.White, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Image(painterResource(R.drawable.logo), null, Modifier.size(56.dp))
                }
                Spacer(Modifier.height(12.dp))
                Wordmark(34, 34)
                Spacer(Modifier.height(6.dp))
                Text(Brand.slogan, color = IceMute, fontSize = 13.sp)
                Spacer(Modifier.height(4.dp))
                Text(Brand.tagline, color = Color(0xFF7AA8C4), fontSize = 12.sp)
            }

            Spacer(Modifier.height(22.dp))
            Column(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(22.dp))
                    .background(Color.White.copy(alpha = 0.94f))
                    .border(1.dp, Color.White, RoundedCornerShape(22.dp))
                    .padding(18.dp)
            ) {
                Text("欢迎回来", color = IceCyan, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(4.dp))
                Text(Brand.loginHint, color = IceMute, fontSize = 13.sp)
                Spacer(Modifier.height(16.dp))

                if (!showComplete) {
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFFF3F6FA))
                            .padding(4.dp)
                    ) {
                        listOf("account" to "账号登录", "mobile" to "手机登录").forEach { (key, label) ->
                            Box(
                                Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(if (mode == key) Color.White else Color.Transparent)
                                    .clickable { mode = key }
                                    .padding(vertical = 10.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    label,
                                    color = if (mode == key) IceInk else IceMute,
                                    fontWeight = if (mode == key) FontWeight.SemiBold else FontWeight.Normal
                                )
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))

                    if (mode == "account") {
                        IceField("账号", username, "请输入账号", { username = it })
                        Spacer(Modifier.height(12.dp))
                        IceField(
                            "密码", password, "请输入密码", { password = it },
                            visualTransformation = PasswordVisualTransformation()
                        )
                    } else {
                        IceField(
                            "手机号", mobile, "请输入手机号",
                            { mobile = it.filter(Char::isDigit).take(11) },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
                        )
                        Spacer(Modifier.height(12.dp))
                        IceField(
                            "短信验证码", smsCode, "请输入验证码",
                            { smsCode = it.filter(Char::isDigit).take(6) },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            trailing = {
                                Text(
                                    if (smsLeft > 0) "${smsLeft}s" else "发送验证码",
                                    color = if (smsLeft > 0) IceMute else IceCyan,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    modifier = Modifier.clickable(enabled = smsLeft == 0) {
                                        scope.launch {
                                            if (!Regex("^1[3-9]\\d{9}$").matches(mobile)) {
                                                toast("请输入正确手机号"); return@launch
                                            }
                                            if (captchaEnabled && captchaValue.isBlank()) {
                                                toast("请先填写图形验证码"); return@launch
                                            }
                                            runCatching {
                                                repo.sendCode(mobile, captchaKey, captchaValue)
                                                toast("验证码已发送")
                                                smsLeft = 60
                                                loadCaptcha()
                                            }.onFailure {
                                                loadCaptcha()
                                                toast((it as? ApiException)?.message ?: "发送失败")
                                            }
                                        }
                                    }
                                )
                            }
                        )
                    }

                    if (captchaEnabled) {
                        Spacer(Modifier.height(12.dp))
                        IceField("安全验证", captchaValue, captchaTip.ifBlank { "请输入验证码" }, { captchaValue = it })
                        Spacer(Modifier.height(8.dp))
                        CaptchaImage(captchaImage) { scope.launch { loadCaptcha() } }
                    }

                    Spacer(Modifier.height(16.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Checkbox(
                            checked = agreed,
                            onCheckedChange = { agreed = it },
                            colors = CheckboxDefaults.colors(checkedColor = IceCyan)
                        )
                        Text("我已阅读并同意用户协议与隐私政策", color = IceMute, fontSize = 12.sp)
                    }
                    Spacer(Modifier.height(12.dp))
                    IcePrimaryButton(
                        text = if (logging) "登录中..." else "登录",
                        loading = logging,
                        onClick = {
                            scope.launch {
                                if (!ensureAgreement()) return@launch
                                logging = true
                                runCatching {
                                    if (mode == "account") {
                                        if (username.isBlank() || password.isBlank()) error("请输入账号和密码")
                                        if (captchaEnabled && captchaValue.isBlank()) error("请先完成安全验证")
                                        val token = repo.loginAccount(
                                            username, password,
                                            if (captchaEnabled) captchaKey else null,
                                            if (captchaEnabled) captchaValue else null
                                        )
                                        handleSuccess(token)
                                    } else {
                                        if (!Regex("^1[3-9]\\d{9}$").matches(mobile)) error("请输入正确手机号")
                                        if (smsCode.isBlank()) error("请输入短信验证码")
                                        val token = repo.loginMobile(mobile, smsCode)
                                        if (token.needCompleteProfile) {
                                            pending = token
                                            realName = ""
                                            roleId = token.roleIdList.firstOrNull()
                                            gender = 2
                                            showComplete = true
                                            toast(if (token.firstLogin) "首次登录，请完善信息" else "请完善信息后继续")
                                        } else {
                                            handleSuccess(token)
                                        }
                                    }
                                }.onFailure {
                                    if (mode == "account") loadCaptcha()
                                    toast((it as? ApiException)?.message ?: it.message ?: "登录失败")
                                }
                                logging = false
                            }
                        }
                    )
                } else {
                    Text("完善信息", color = IceInk, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.height(6.dp))
                    Text("选择身份并补充资料后进入系统。首次默认密码为当前手机号。", color = IceMute, fontSize = 13.sp)
                    Spacer(Modifier.height(14.dp))
                    Text("选择身份", color = IceMute, fontSize = 13.sp)
                    Spacer(Modifier.height(8.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf(2L to "研发", 3L to "运维", 4L to "产品").forEach { (id, label) ->
                            Box(
                                Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(if (roleId == id) IceCyan.copy(0.12f) else Color(0xFFF3F6FA))
                                    .border(1.dp, if (roleId == id) IceCyan else Color.Transparent, RoundedCornerShape(12.dp))
                                    .clickable { roleId = id }
                                    .padding(vertical = 14.dp),
                                contentAlignment = Alignment.Center
                            ) { Text(label, fontWeight = FontWeight.SemiBold, color = IceInk) }
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                    IceField("姓名", realName, "请输入真实姓名", { realName = it })
                    Spacer(Modifier.height(12.dp))
                    IceField("手机号", pending?.mobile ?: mobile, "", {}, tip = "不可修改")
                    Spacer(Modifier.height(12.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf(0 to "男", 1 to "女", 2 to "未知").forEach { (g, label) ->
                            Box(
                                Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(if (gender == g) IceCyan.copy(0.12f) else Color(0xFFF3F6FA))
                                    .clickable { gender = g }
                                    .padding(vertical = 12.dp),
                                contentAlignment = Alignment.Center
                            ) { Text(label) }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    IcePrimaryButton("完成并进入系统", loading = completing) {
                        scope.launch {
                            if (realName.isBlank()) { toast("请输入真实姓名"); return@launch }
                            if (roleId == null) { toast("请选择身份角色"); return@launch }
                            completing = true
                            runCatching {
                                val token = repo.completeProfile(
                                    CompleteProfileRequest(
                                        userId = pending?.userId,
                                        roleId = roleId,
                                        realName = realName,
                                        gender = gender,
                                        mobile = pending?.mobile ?: mobile,
                                        password = Sm2Util.encrypt(pending?.mobile ?: mobile)
                                    )
                                )
                                handleSuccess(token)
                            }.onFailure { toast((it as? ApiException)?.message ?: "提交失败") }
                            completing = false
                        }
                    }
                    Spacer(Modifier.height(10.dp))
                    Text(
                        "返回登录",
                        color = IceMute,
                        modifier = Modifier
                            .align(Alignment.CenterHorizontally)
                            .clickable { showComplete = false },
                        fontSize = 13.sp
                    )
                }

                Spacer(Modifier.height(14.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf("国密加密", "统一认证", "操作审计").forEach {
                        Text(
                            it,
                            modifier = Modifier
                                .clip(RoundedCornerShape(999.dp))
                                .background(IceCyan.copy(0.08f))
                                .padding(horizontal = 10.dp, vertical = 4.dp),
                            color = Color(0xFF0284C7),
                            fontSize = 11.sp
                        )
                    }
                }
            }
            Spacer(Modifier.height(18.dp))
            Text(
                "${Brand.footer} · 安全登录",
                color = IceMute,
                fontSize = 12.sp,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )
            Spacer(Modifier.height(20.dp))
        }
    }
}

@Composable
private fun CaptchaImage(image: String?, onRefresh: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        val bitmap = remember(image) {
            image?.substringAfter("base64,", image)?.let { raw ->
                runCatching {
                    val bytes = Base64.decode(raw, Base64.DEFAULT)
                    BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.asImageBitmap()
                }.getOrNull()
            }
        }
        Box(
            Modifier
                .width(120.dp)
                .height(44.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(Color(0xFFF3F6FA))
                .clickable(onClick = onRefresh),
            contentAlignment = Alignment.Center
        ) {
            if (bitmap != null) {
                Image(bitmap, null, Modifier.fillMaxSize())
            } else {
                Text("点击刷新", color = IceMute, fontSize = 12.sp)
            }
        }
        Spacer(Modifier.width(10.dp))
        Text("看不清？点击刷新", color = IceMute, fontSize = 12.sp, modifier = Modifier.clickable(onClick = onRefresh))
    }
}
