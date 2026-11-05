package net.icejz.app.ui.splash

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import net.icejz.app.R
import net.icejz.app.config.Brand
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute

@Composable
fun SplashScreen(onFinished: () -> Unit) {
    var phase by remember { mutableIntStateOf(0) }
    var progress by remember { mutableIntStateOf(0) }
    var ready by remember { mutableStateOf(false) }
    var leaving by remember { mutableStateOf(false) }
    val leaveAlpha = remember { Animatable(1f) }
    val infinite = rememberInfiniteTransition(label = "splash")
    val breathe by infinite.animateFloat(
        initialValue = 1f,
        targetValue = 1.03f,
        animationSpec = infiniteRepeatable(tween(1600), RepeatMode.Reverse),
        label = "breathe"
    )

    LaunchedEffect(Unit) {
        delay(50); phase = 1
        delay(330); phase = 2
        delay(900); phase = 3
        val start = System.currentTimeMillis()
        while (progress < 100) {
            val t = ((System.currentTimeMillis() - start) / 1400f).coerceIn(0f, 1f)
            val eased = 1 - (1 - t) * (1 - t) * (1 - t)
            progress = (eased * 100).toInt()
            delay(32)
        }
        progress = 100
        ready = true
        delay(1500)
        leaving = true
        leaveAlpha.animateTo(0f, tween(450))
        onFinished()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .alpha(leaveAlpha.value)
            .scale(if (leaving) 1.05f else 1f)
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFFEEF6FB), Color(0xFFF3F6FA), Color(0xFFF8FAFC))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        colors = listOf(IceCyan.copy(alpha = 0.14f), Color.Transparent),
                        radius = 900f
                    )
                )
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 28.dp)
                .alpha(if (phase >= 1) 1f else 0f)
        ) {
            Text(
                "STUDIO",
                color = Color(0xFF7AA8C4),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 4.sp
            )
            Spacer(Modifier.height(18.dp))

            Box(contentAlignment = Alignment.Center, modifier = Modifier.scale(if (ready) breathe else 1f)) {
                Box(
                    Modifier
                        .size(148.dp)
                        .clip(CircleShape)
                        .background(IceCyan.copy(alpha = 0.12f))
                )
                Box(
                    Modifier
                        .size(108.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(Color.White.copy(alpha = 0.96f), Color(0xFFEAF7FD))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(R.drawable.xiaobing_main),
                        contentDescription = null,
                        modifier = Modifier.size(76.dp),
                        contentScale = ContentScale.Fit
                    )
                }
            }

            Spacer(Modifier.height(28.dp))
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.alpha(if (phase >= 2) 1f else 0f)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .clip(RoundedCornerShape(999.dp))
                        .background(Color.White.copy(alpha = 0.88f))
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Box(Modifier.size(8.dp).clip(CircleShape).background(IceCyan))
                    Spacer(Modifier.width(8.dp))
                    Text("ICECORE", color = Color(0xFF0284C7), fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 2.sp)
                    Spacer(Modifier.width(8.dp))
                    Text(
                        "ENGINE",
                        modifier = Modifier
                            .clip(RoundedCornerShape(999.dp))
                            .background(IceCyan.copy(alpha = 0.08f))
                            .padding(horizontal = 8.dp, vertical = 2.dp),
                        color = Color(0xFF0284C7),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                Spacer(Modifier.height(14.dp))
                Row {
                    Text("ICE", color = IceInk, fontSize = 42.sp, fontWeight = FontWeight.ExtraBold)
                    Text("JZ", color = IceCyan, fontSize = 42.sp, fontWeight = FontWeight.ExtraBold)
                }
                Spacer(Modifier.height(10.dp))
                Text(Brand.slogan, color = Color(0xFF3D4B5C), fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(6.dp))
                Text(Brand.tagline, color = IceMute, fontSize = 12.sp)
            }

            Spacer(Modifier.height(36.dp))
            Column(
                modifier = Modifier
                    .fillMaxWidth(0.78f)
                    .alpha(if (phase >= 3) 1f else 0f)
            ) {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(RoundedCornerShape(999.dp))
                        .background(Color(0xFFE8EEF5))
                ) {
                    Box(
                        Modifier
                            .fillMaxWidth(progress / 100f)
                            .height(8.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(Brush.horizontalGradient(listOf(IceCyan, Color(0xFF7DD3FC))))
                    )
                }
                Spacer(Modifier.height(10.dp))
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Box(Modifier.size(6.dp).clip(CircleShape).background(if (ready) IceCyan else IceMute))
                    Spacer(Modifier.width(8.dp))
                    Text(
                        if (ready) "准备就绪" else "加载中",
                        color = if (ready) Color(0xFF0284C7) else IceMute,
                        fontSize = 12.sp,
                        letterSpacing = 2.sp,
                        modifier = Modifier.weight(1f)
                    )
                    Text("$progress%", color = if (ready) Color(0xFF0284C7) else IceInk, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
