package net.icejz.app.ui.guide

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
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.ui.components.IcePrimaryButton
import net.icejz.app.ui.components.Wordmark
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

private data class GuidePage(val title: String, val desc: String)

@Composable
fun GuideScreen(onDone: () -> Unit) {
    val pages = listOf(
        GuidePage("欢迎使用 ICEJZ", Brand.description),
        GuidePage("工作台一览", "与管理端同源数据，移动端快速查阅用户、机构、角色与消息。"),
        GuidePage("小冰助手", "随时唤起 AI 助手，整理待办、快速打开常用系统模块。")
    )
    var page by remember { mutableIntStateOf(0) }

    Column(
        Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFFEEF6FB), Color(0xFFF3F6FA))))
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(20.dp)
    ) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            Text(
                "跳过",
                color = IceMute,
                modifier = Modifier
                    .clip(RoundedCornerShape(999.dp))
                    .background(Color.White.copy(0.8f))
                    .clickable(onClick = onDone)
                    .padding(horizontal = 14.dp, vertical = 8.dp),
                fontSize = 13.sp
            )
        }
        Spacer(Modifier.height(24.dp))
        Column(
            Modifier
                .weight(1f)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Image(painterResource(R.drawable.xiaobing_main), null, Modifier.size(120.dp))
            Spacer(Modifier.height(24.dp))
            Wordmark(30, 30)
            Spacer(Modifier.height(18.dp))
            Text(pages[page].title, color = IceInk, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(10.dp))
            Text(
                pages[page].desc,
                color = IceMute,
                fontSize = 14.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 12.dp)
            )
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
            repeat(pages.size) { i ->
                Box(
                    Modifier
                        .padding(4.dp)
                        .size(if (page == i) 18.dp else 8.dp, 8.dp)
                        .clip(CircleShape)
                        .background(if (page == i) IceCyan else IceCyan.copy(0.25f))
                )
            }
        }
        Spacer(Modifier.height(20.dp))
        IcePrimaryButton(
            text = if (page == pages.lastIndex) "进入首页" else "下一步"
        ) {
            if (page == pages.lastIndex) onDone()
            else page += 1
        }
        Spacer(Modifier.height(12.dp))
    }
}
