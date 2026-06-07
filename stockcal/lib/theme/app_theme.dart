import 'package:flutter/material.dart';

class AppTheme {
  // Morandi 莫兰迪色系 - 背景
  static const Color bg = Color(0xFFE5DDD5);
  static const Color bgSecondary = Color(0xFFEDE7E0);
  static const Color card = Color(0xFFF9F6F2);
  static const Color cardHover = Color(0xFFF0EBE4);
  static const Color text = Color(0xFF3E3A37);
  static const Color textSecondary = Color(0xFF9B9590);
  static const Color textMuted = Color(0xFFBFB9B3);
  static const Color border = Color(0xFFD9D2CA);

  // Morandi event colors - 独立常量
  static const Color eventEarnings = Color(0xFFC49B8A);
  static const Color eventShareholder = Color(0xFFA8B5A2);
  static const Color eventProduct = Color(0xFFD4AF8D);
  static const Color eventDividend = Color(0xFF9BAEBF);
  static const Color eventInvestor = Color(0xFFB8A5C0);
  static const Color eventOther = Color(0xFFB5B0A8);

  // Event colors list (non-const for runtime use)
  static List<Color> get eventColors => [
        eventEarnings,
        eventShareholder,
        eventProduct,
        eventDividend,
        eventInvestor,
        eventOther,
      ];

  // Stock colors
  static const Color stock0 = Color(0xFFC49B8A);
  static const Color stock1 = Color(0xFFA8B5A2);
  static const Color stock2 = Color(0xFF9BAEBF);
  static const Color stock3 = Color(0xFFD4AF8D);
  static const Color stock4 = Color(0xFFB8A5C0);
  static const Color stock5 = Color(0xFFC4A882);
  static const Color stock6 = Color(0xFF9BB5B0);
  static const Color stock7 = Color(0xFFC2A0AE);
  static const Color stock8 = Color(0xFFA898C0);
  static const Color stock9 = Color(0xFFB0A090);
  static const Color stock10 = Color(0xFFC8B8A8);
  static const Color stock11 = Color(0xFFA0B0B8);

  static const List<Color> stockColors = [
    stock0, stock1, stock2, stock3, stock4, stock5,
    stock6, stock7, stock8, stock9, stock10, stock11,
  ];

  // 快捷颜色别名
  static const Color accent = eventEarnings;

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          primary: accent,
          surface: card,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      );
}
