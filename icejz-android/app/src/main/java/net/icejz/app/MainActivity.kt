package net.icejz.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import net.icejz.app.ui.navigation.IcejzNavHost
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IcejzTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            IcejzTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = IceCanvas) {
                    IcejzNavHost()
                }
            }
        }
    }
}
