import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/app_cache.dart';
import 'package:icejz_app/navigation/routes.dart';
import 'package:icejz_app/ui/assistant/assistant_page.dart';
import 'package:icejz_app/ui/guide/guide_page.dart';
import 'package:icejz_app/ui/login/login_page.dart';
import 'package:icejz_app/ui/main/main_shell.dart';
import 'package:icejz_app/ui/message/message_page.dart';
import 'package:icejz_app/ui/mine/user_pages.dart';
import 'package:icejz_app/ui/splash/splash_page.dart';
import 'package:icejz_app/ui/sys/sys_pages.dart';

class AppRouter {
  AppRouter(this.cache);

  final AppCache cache;
  final _rootKey = GlobalKey<NavigatorState>();
  int authEpoch = 0;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => SplashPage(
          onFinished: () {
            final next = () {
              final token = cache.getToken();
              if (token == null || token.isEmpty) return Routes.login;
              if (!cache.isGuideDone()) return Routes.guide;
              return Routes.main;
            }();
            context.go(next);
          },
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => LoginPage(
          onLoggedIn: () {
            final next = cache.isGuideDone() ? Routes.main : Routes.guide;
            context.go(next);
          },
        ),
      ),
      GoRoute(
        path: Routes.guide,
        builder: (context, state) => GuidePage(
          onDone: () async {
            await cache.markGuideDone();
            if (context.mounted) context.go(Routes.main);
          },
        ),
      ),
      GoRoute(
        path: Routes.main,
        builder: (context, state) => MainShell(
          authEpoch: authEpoch,
          onNavigate: (route) => context.push(route),
          onLogout: () => context.go(Routes.login),
        ),
      ),
      GoRoute(
        path: Routes.message,
        builder: (context, state) =>
            MessagePage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.sysUser,
        builder: (context, state) =>
            UserListPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.sysOrg,
        builder: (context, state) =>
            OrgListPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.sysRole,
        builder: (context, state) =>
            RoleListPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.userInfo,
        builder: (context, state) => UserInfoPage(
          onBack: () => context.pop(),
          onEdit: () => context.push(Routes.userEdit),
        ),
      ),
      GoRoute(
        path: Routes.userEdit,
        builder: (context, state) =>
            UserEditPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.password,
        builder: (context, state) =>
            PasswordPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.devices,
        builder: (context, state) =>
            DevicesPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => SettingsPage(
          onBack: () => context.pop(),
          onOpenAbout: () => context.push(Routes.about),
          onOpenDevices: () => context.push(Routes.devices),
          onOpenPassword: () => context.push(Routes.password),
        ),
      ),
      GoRoute(
        path: Routes.about,
        builder: (context, state) => AboutPage(onBack: () => context.pop()),
      ),
      GoRoute(
        path: Routes.assistant,
        builder: (context, state) =>
            AssistantPage(onBack: () => context.pop()),
      ),
    ],
  );

  void bindUnauthorized() {
    ApiClient.instance.setUnauthorizedHandler(() {
      authEpoch += 1;
      router.go(Routes.login);
    });
  }
}
