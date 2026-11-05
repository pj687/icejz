package net.icejz.app.ui.main

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Apps
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import net.icejz.app.ui.home.HomeScreen
import net.icejz.app.ui.mine.MineScreen
import net.icejz.app.ui.theme.IceCanvas
import net.icejz.app.ui.theme.IceCyan
import net.icejz.app.ui.theme.IceMute
import net.icejz.app.ui.workbench.WorkbenchScreen

private data class TabItem(val label: String, val icon: ImageVector)

@Composable
fun MainScreen(
    authEpoch: Int = 0,
    onNavigate: (String) -> Unit,
    onLogout: () -> Unit
) {
    var tab by remember { mutableIntStateOf(0) }
    val tabs = listOf(
        TabItem("首页", Icons.Outlined.Home),
        TabItem("工作台", Icons.Outlined.Apps),
        TabItem("我的", Icons.Outlined.Person)
    )

    Scaffold(
        containerColor = IceCanvas,
        bottomBar = {
            NavigationBar(containerColor = Color.White.copy(alpha = 0.96f), tonalElevation = 0.dp) {
                tabs.forEachIndexed { index, item ->
                    NavigationBarItem(
                        selected = tab == index,
                        onClick = { tab = index },
                        icon = { Icon(item.icon, contentDescription = item.label) },
                        label = { Text(item.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = IceCyan,
                            selectedTextColor = IceCyan,
                            unselectedIconColor = IceMute,
                            unselectedTextColor = IceMute,
                            indicatorColor = IceCyan.copy(alpha = 0.12f)
                        )
                    )
                }
            }
        }
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            when (tab) {
                0 -> HomeScreen(
                    authEpoch = authEpoch,
                    onNavigate = onNavigate,
                    onOpenWorkbench = { tab = 1 }
                )
                1 -> WorkbenchScreen(authEpoch = authEpoch, onNavigate = onNavigate)
                else -> MineScreen(
                    authEpoch = authEpoch,
                    onNavigate = onNavigate,
                    onLogout = onLogout
                )
            }
        }
    }
}
