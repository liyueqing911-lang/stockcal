import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'dark_theme.dart';

/// StockCal 主题入口
///
/// 根据 [brightness] 返回对应的 ThemeData。
/// 通过 [ThemeState] Provider 驱动切换。
class AppTheme {
  AppTheme._();

  /// 莫兰迪浅色主题
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
          surface: AppColors.card,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.5,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodySmall: TextStyle(color: AppColors.textMuted),
        ),
      );

  /// 暗黑主题
  static ThemeData get dark => DarkTheme.theme;

  /// 根据亮色/暗色获取主题
  static ThemeData of(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
