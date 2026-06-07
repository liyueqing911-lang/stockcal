import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_localizations.dart';
import 'providers/theme_state.dart';
import 'pages/main_screen.dart';

/// StockCal 应用根组件
class StockCalApp extends StatelessWidget {
  const StockCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();

    return MaterialApp(
      title: 'StockCal - 炒股日历',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeState.themeMode,
      localizationsDelegates: AppLocalizations.delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh', 'CN'),
      home: const MainScreen(),
    );
  }
}
