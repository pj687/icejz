package net.icejz.app.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val IceTypography = Typography(
    displayLarge = TextStyle(fontWeight = FontWeight.Bold, fontSize = 40.sp, color = IceInk),
    headlineLarge = TextStyle(fontWeight = FontWeight.Bold, fontSize = 28.sp, color = IceInk),
    headlineMedium = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 22.sp, color = IceInk),
    titleLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 18.sp, color = IceInk),
    titleMedium = TextStyle(fontWeight = FontWeight.Medium, fontSize = 16.sp, color = IceInk),
    bodyLarge = TextStyle(fontWeight = FontWeight.Normal, fontSize = 15.sp, color = IceInk),
    bodyMedium = TextStyle(fontWeight = FontWeight.Normal, fontSize = 14.sp, color = IceInkSoft),
    bodySmall = TextStyle(fontWeight = FontWeight.Normal, fontSize = 12.sp, color = IceMute),
    labelLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = IceInk)
)
