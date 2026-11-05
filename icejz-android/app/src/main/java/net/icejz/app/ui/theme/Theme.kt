package net.icejz.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val IceColorScheme = lightColorScheme(
    primary = IceCyan,
    onPrimary = Color.White,
    secondary = IceCyanSoft,
    onSecondary = IceInk,
    background = IceCanvas,
    onBackground = IceInk,
    surface = Color.White,
    onSurface = IceInk,
    error = IceDanger,
    onError = Color.White
)

@Composable
fun IcejzTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = IceColorScheme,
        typography = IceTypography,
        content = content
    )
}
