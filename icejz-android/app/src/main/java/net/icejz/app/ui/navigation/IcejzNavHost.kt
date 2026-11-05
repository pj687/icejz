package net.icejz.app.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import net.icejz.app.IcejzApp
import net.icejz.app.data.remote.ApiClient
import net.icejz.app.ui.assistant.AssistantScreen
import net.icejz.app.ui.guide.GuideScreen
import net.icejz.app.ui.login.LoginScreen
import net.icejz.app.ui.main.MainScreen
import net.icejz.app.ui.message.MessageScreen
import net.icejz.app.ui.mine.AboutScreen
import net.icejz.app.ui.mine.DevicesScreen
import net.icejz.app.ui.mine.PasswordScreen
import net.icejz.app.ui.mine.SettingsScreen
import net.icejz.app.ui.mine.UserEditScreen
import net.icejz.app.ui.mine.UserInfoScreen
import net.icejz.app.ui.splash.SplashScreen
import net.icejz.app.ui.sys.OrgListScreen
import net.icejz.app.ui.sys.RoleListScreen
import net.icejz.app.ui.sys.UserListScreen

@Composable
fun IcejzNavHost(
    navController: NavHostController = rememberNavController()
) {
    var authEpoch by remember { mutableStateOf(0) }

    LaunchedEffect(Unit) {
        ApiClient.setUnauthorizedHandler {
            authEpoch += 1
            navController.navigate(Routes.Login) {
                popUpTo(0) { inclusive = true }
            }
        }
    }

    NavHost(navController = navController, startDestination = Routes.Splash) {
        composable(Routes.Splash) {
            SplashScreen(
                onFinished = {
                    val cache = IcejzApp.instance.cache
                    val next = when {
                        cache.getToken().isNullOrBlank() -> Routes.Login
                        !cache.isGuideDone() -> Routes.Guide
                        else -> Routes.Main
                    }
                    navController.navigate(next) {
                        popUpTo(Routes.Splash) { inclusive = true }
                    }
                }
            )
        }
        composable(Routes.Login) {
            LoginScreen(
                onLoggedIn = {
                    val next = if (IcejzApp.instance.cache.isGuideDone()) Routes.Main else Routes.Guide
                    navController.navigate(next) {
                        popUpTo(Routes.Login) { inclusive = true }
                    }
                }
            )
        }
        composable(Routes.Guide) {
            GuideScreen(
                onDone = {
                    IcejzApp.instance.cache.markGuideDone()
                    navController.navigate(Routes.Main) {
                        popUpTo(Routes.Guide) { inclusive = true }
                    }
                }
            )
        }
        composable(Routes.Main) {
            MainScreen(
                authEpoch = authEpoch,
                onNavigate = { route -> navController.navigate(route) },
                onLogout = {
                    navController.navigate(Routes.Login) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }
        composable(Routes.Message) { MessageScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.SysUser) { UserListScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.SysOrg) { OrgListScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.SysRole) { RoleListScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.UserInfo) {
            UserInfoScreen(
                onBack = { navController.popBackStack() },
                onEdit = { navController.navigate(Routes.UserEdit) }
            )
        }
        composable(Routes.UserEdit) { UserEditScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.Password) { PasswordScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.Devices) { DevicesScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.Settings) {
            SettingsScreen(
                onBack = { navController.popBackStack() },
                onOpenAbout = { navController.navigate(Routes.About) },
                onOpenDevices = { navController.navigate(Routes.Devices) },
                onOpenPassword = { navController.navigate(Routes.Password) }
            )
        }
        composable(Routes.About) { AboutScreen(onBack = { navController.popBackStack() }) }
        composable(Routes.Assistant) { AssistantScreen(onBack = { navController.popBackStack() }) }
    }
}
