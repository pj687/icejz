package net.icejz.app.ui.message

import android.widget.Toast
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import net.icejz.app.data.model.MessageItem
import net.icejz.app.data.remote.ApiException
import net.icejz.app.data.repository.HomeRepository
import net.icejz.app.ui.components.EmptyState
import net.icejz.app.ui.components.IceNavBar
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

@Composable
fun MessageScreen(onBack: () -> Unit) {
    val repo = remember { HomeRepository() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var list by remember { mutableStateOf<List<MessageItem>>(emptyList()) }
    var loading by remember { mutableStateOf(true) }

    fun refresh() {
        scope.launch {
            loading = true
            runCatching { list = repo.messagePage().list }
                .onFailure { Toast.makeText(context, (it as? ApiException)?.message ?: "加载失败", Toast.LENGTH_SHORT).show() }
            loading = false
        }
    }

    LaunchedEffect(Unit) { refresh() }

    Column(Modifier.fillMaxSize().background(IceCanvas).statusBarsPadding()) {
        IceNavBar(
            title = "我的消息",
            onBack = onBack,
            trailing = {
                Text(
                    "全部已读",
                    color = IceCyan,
                    fontSize = 13.sp,
                    modifier = Modifier
                        .padding(end = 12.dp)
                        .clickable {
                            scope.launch {
                                runCatching { repo.readAll(); refresh() }
                            }
                        }
                )
            }
        )
        if (!loading && list.isEmpty()) {
            EmptyState("暂无站内消息", "系统通知会显示在这里")
        } else {
            LazyColumn(Modifier.fillMaxSize().padding(horizontal = 16.dp)) {
                items(list, key = { it.id ?: it.hashCode().toLong() }) { item ->
                    val unread = item.readStatus != 1
                    Column(
                        Modifier
                            .fillMaxWidth()
                            .padding(vertical = 6.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(Color.White)
                            .clickable {
                                scope.launch {
                                    item.id?.let { id ->
                                        runCatching { repo.readMessage(id) }
                                        refresh()
                                    }
                                }
                            }
                            .padding(14.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (unread) {
                                Box(Modifier.size(8.dp).clip(CircleShape).background(IceCyan))
                                Spacer(Modifier.size(8.dp))
                            }
                            Text(
                                item.title ?: "系统通知",
                                fontWeight = FontWeight.SemiBold,
                                color = IceInk,
                                modifier = Modifier.weight(1f)
                            )
                        }
                        Spacer(Modifier.height(6.dp))
                        Text(item.content.orEmpty(), color = IceMute, fontSize = 13.sp, maxLines = 2)
                        Spacer(Modifier.height(6.dp))
                        Text(item.sendTime ?: item.createTime.orEmpty(), color = IceMute, fontSize = 11.sp)
                    }
                }
            }
        }
    }
}
