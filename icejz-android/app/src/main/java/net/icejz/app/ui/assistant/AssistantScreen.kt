package net.icejz.app.ui.assistant

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
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import net.icejz.app.R
import net.icejz.app.data.remote.ApiException
import net.icejz.app.data.repository.AiRepository
import net.icejz.app.ui.components.IceNavBar
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

private data class ChatBubble(val id: Long, val mine: Boolean, val content: String)

@Composable
fun AssistantScreen(onBack: () -> Unit) {
    val repo = remember { AiRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    val messages = remember { mutableStateListOf<ChatBubble>() }
    var input by remember { mutableStateOf("") }
    var sending by remember { mutableStateOf(false) }
    var sessionId by remember { mutableLongStateOf(0L) }
    var greeting by remember { mutableStateOf("你好，我是小冰助手，有什么可以帮你？") }
    val listState = rememberLazyListState()
    var seq by remember { mutableLongStateOf(1L) }

    LaunchedEffect(Unit) {
        runCatching {
            repo.robot()?.greeting?.takeIf { it.isNotBlank() }?.let { greeting = it }
        }
        messages += ChatBubble(seq++, false, greeting)
    }

    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.lastIndex)
        }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(IceCanvas)
            .statusBarsPadding()
            .navigationBarsPadding()
            .imePadding()
    ) {
        IceNavBar("小冰助手", onBack)
        Row(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Image(painterResource(R.drawable.xiaobing_head), null, Modifier.size(36.dp).clip(CircleShape))
            Spacer(Modifier.size(10.dp))
            Column {
                Text("小冰", fontWeight = FontWeight.SemiBold, color = IceInk)
                Text("ICEJZ AI Assistant", color = IceMute, fontSize = 12.sp)
            }
        }
        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(messages, key = { it.id }) { msg ->
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = if (msg.mine) Arrangement.End else Arrangement.Start
                ) {
                    Box(
                        Modifier
                            .widthIn(max = 280.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (msg.mine) IceCyan else Color.White)
                            .padding(horizontal = 12.dp, vertical = 10.dp)
                    ) {
                        Text(msg.content, color = if (msg.mine) Color.White else IceInk, fontSize = 14.sp)
                    }
                }
            }
        }
        Row(
            Modifier
                .fillMaxWidth()
                .padding(12.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(Color.White)
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            BasicTextField(
                value = input,
                onValueChange = { input = it },
                modifier = Modifier.weight(1f).padding(vertical = 8.dp),
                textStyle = TextStyle(color = IceInk, fontSize = 15.sp),
                cursorBrush = SolidColor(IceCyan),
                decorationBox = { inner ->
                    if (input.isEmpty()) Text("输入问题…", color = Color(0xFF9AA8B6))
                    inner()
                }
            )
            Spacer(Modifier.size(8.dp))
            Box(
                Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (sending || input.isBlank()) Color(0xFFC5CED6) else IceCyan)
                    .clickable(enabled = !sending && input.isNotBlank()) {
                        val text = input.trim()
                        if (text.isEmpty()) return@clickable
                        scope.launch {
                            messages += ChatBubble(seq++, true, text)
                            input = ""
                            sending = true
                            runCatching {
                                val reply = repo.chat(
                                    text,
                                    sessionId.takeIf { it > 0 }
                                )
                                reply.sessionId?.let { sessionId = it }
                                messages += ChatBubble(
                                    seq++,
                                    false,
                                    reply.content?.ifBlank { "我暂时没有合适的回答" }
                                        ?: "我暂时没有合适的回答"
                                )
                            }.onFailure {
                                messages += ChatBubble(
                                    seq++,
                                    false,
                                    (it as? ApiException)?.message ?: "请求失败，请稍后重试"
                                )
                                Toast.makeText(
                                    context,
                                    (it as? ApiException)?.message ?: "发送失败",
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                            sending = false
                        }
                    }
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                if (sending) {
                    CircularProgressIndicator(Modifier.size(16.dp), color = Color.White, strokeWidth = 2.dp)
                } else {
                    Text("发送", color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        Spacer(Modifier.height(4.dp))
    }
}
