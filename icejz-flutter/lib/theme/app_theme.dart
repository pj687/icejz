import 'package:flutter/material.dart';
import 'package:icejz_app/theme/app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.light(
    primary: AppColors.iceCyan,
    onPrimary: Colors.white,
    secondary: AppColors.iceCyanSoft,
    onSecondary: AppColors.iceInk,
    surface: Colors.white,
    onSurface: AppColors.iceInk,
    error: AppColors.iceDanger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.iceCanvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.iceCanvas,
      foregroundColor: AppColors.iceInk,
      elevation: 0,
      centerTitle: false,
    ),
    fontFamily: null,
  );
}
