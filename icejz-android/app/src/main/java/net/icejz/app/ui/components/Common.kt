package net.icejz.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceInk
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.ui.theme.IcePanel

@Composable
fun IceNavBar(
    title: String,
    onBack: (() -> Unit)? = null,
    trailing: @Composable (() -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(IceCanvas.copy(alpha = 0.92f))
            .padding(horizontal = 8.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (onBack != null) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "返回", tint = IceInk)
            }
        } else {
            Spacer(Modifier.width(48.dp))
        }
        Text(
            text = title,
            modifier = Modifier.weight(1f),
            style = TextStyle(fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IceInk)
        )
        trailing?.invoke() ?: Spacer(Modifier.width(48.dp))
    }
}

@Composable
fun IceCard(modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(IcePanel)
            .border(1.dp, Color.White.copy(alpha = 0.9f), RoundedCornerShape(18.dp))
            .padding(16.dp)
    ) { content() }
}

@Composable
fun IcePrimaryButton(
    text: String,
    loading: Boolean = false,
    enabled: Boolean = true,
    onClick: () -> Unit
) {
    val active = enabled && !loading
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(
                if (active) Brush.horizontalGradient(listOf(IceCyan, Color(0xFF2BB8EF)))
                else Brush.horizontalGradient(listOf(Color(0xFFC5CED6), Color(0xFFC5CED6)))
            )
            .clickable(enabled = active, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        if (loading) {
            CircularProgressIndicator(modifier = Modifier.size(22.dp), color = Color.White, strokeWidth = 2.dp)
        } else {
            Text(text, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
        }
    }
}

@Composable
fun IceField(
    label: String,
    value: String,
    placeholder: String,
    onValueChange: (String) -> Unit,
    visualTransformation: VisualTransformation = VisualTransformation.None,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    trailing: @Composable (() -> Unit)? = null,
    tip: String? = null,
    error: Boolean = false
) {
    Column(Modifier.fillMaxWidth()) {
        Text(label, color = IceMute, fontSize = 13.sp, fontWeight = FontWeight.Medium)
        Spacer(Modifier.height(8.dp))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Color.White)
                .border(
                    1.dp,
                    if (error) Color(0xFFE11D48) else Color(0x140F2337),
                    RoundedCornerShape(14.dp)
                )
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            BasicTextField(
                value = value,
                onValueChange = onValueChange,
                modifier = Modifier.weight(1f),
                singleLine = true,
                textStyle = TextStyle(color = IceInk, fontSize = 15.sp),
                cursorBrush = SolidColor(IceCyan),
                visualTransformation = visualTransformation,
                keyboardOptions = keyboardOptions,
                decorationBox = { inner ->
                    if (value.isEmpty()) {
                        Text(placeholder, color = Color(0xFF9AA8B6), fontSize = 15.sp)
                    }
                    inner()
                }
            )
            trailing?.invoke()
        }
        if (!tip.isNullOrBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(tip, color = if (error) Color(0xFFE11D48) else IceMute, fontSize = 12.sp)
        }
    }
}

@Composable
fun Wordmark(iceSize: Int = 28, jzSize: Int = 28) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text("ICE", color = IceInk, fontSize = iceSize.sp, fontWeight = FontWeight.ExtraBold, letterSpacing = 1.sp)
        Text("JZ", color = IceCyan, fontSize = jzSize.sp, fontWeight = FontWeight.ExtraBold, letterSpacing = 1.sp)
    }
}

@Composable
fun MenuRow(
    title: String,
    hint: String? = null,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(Modifier.weight(1f)) {
            Text(title, color = IceInk, fontSize = 15.sp, fontWeight = FontWeight.Medium)
            if (!hint.isNullOrBlank()) {
                Spacer(Modifier.height(2.dp))
                Text(hint, color = IceMute, fontSize = 12.sp)
            }
        }
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = IceMute)
    }
}

@Composable
fun EmptyState(title: String, desc: String = "") {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(IceCyan.copy(alpha = 0.12f))
        )
        Spacer(Modifier.height(12.dp))
        Text(title, color = IceInk, fontWeight = FontWeight.SemiBold)
        if (desc.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(desc, color = IceMute, fontSize = 13.sp)
        }
    }
}

@Composable
fun SimpleBarChart(values: List<Pair<String, Int>>, modifier: Modifier = Modifier) {
    val max = (values.maxOfOrNull { it.second } ?: 1).coerceAtLeast(1)
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(140.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.Bottom
    ) {
        values.forEach { (label, value) ->
            val barH = ((100f * value / max).coerceAtLeast(4f)).dp
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    Modifier
                        .width(18.dp)
                        .height(barH)
                        .clip(RoundedCornerShape(topStart = 6.dp, topEnd = 6.dp))
                        .background(Brush.verticalGradient(listOf(IceCyan, Color(0xFF7DD3FC))))
                )
                Spacer(Modifier.height(6.dp))
                Text(label, fontSize = 11.sp, color = IceMute)
            }
        }
    }
}
