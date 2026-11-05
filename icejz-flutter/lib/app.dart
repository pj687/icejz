import 'package:flutter/material.dart';
import 'package:icejz_app/data/app_cache.dart';
import 'package:icejz_app/navigation/app_router.dart';
import 'package:icejz_app/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class IcejzApp extends StatefulWidget {
  const IcejzApp({super.key, required this.cache});

  final AppCache cache;

  @override
  State<IcejzApp> createState() => _IcejzAppState();
}

class _IcejzAppState extends State<IcejzApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN');
    _appRouter = AppRouter(widget.cache)..bindUnauthorized();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ICEJZ',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _appRouter.router,
    );
  }
}
