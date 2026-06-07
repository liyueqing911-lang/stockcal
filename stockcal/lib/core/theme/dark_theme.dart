import 'package:flutter/material.dart';
import 'app_colors.dart';

/// StockCal 暗黑模式主题
class DarkTheme {
  DarkTheme._();

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.dark(
          primary: AppColors.eventEarnings,
          surface: AppColors.darkCard,
          onSurface: AppColors.darkText,
          outline: AppColors.darkBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkCard,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 0.5,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
          bodySmall: TextStyle(color: AppColors.darkTextMuted),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkCard,
          contentTextStyle: const TextStyle(color: AppColors.darkText),
        ),
      );
}
