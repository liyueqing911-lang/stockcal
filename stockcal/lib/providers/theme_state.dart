import 'package:flutter/material.dart';

/// 主题状态管理
///
/// 控制暗黑/浅色模式切换，状态持久化到 SharedPreferences。
class ThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// 切换暗黑模式
  void setDarkMode(bool enabled) {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// 切换亮暗
  void toggle() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// 从持久化存储加载
  void loadFromPrefs(bool? isDark) {
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
}
