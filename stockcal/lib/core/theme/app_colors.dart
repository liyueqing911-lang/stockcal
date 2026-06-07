import 'package:flutter/material.dart';

/// StockCal 6色事件体系 + 语义色定义
///
/// 🔴 财报  🟠 产品发布会  🔵 股东大会
/// 🟢 分红  🟣 IPO         ⚪ 投资者会议/其他
class AppColors {
  AppColors._();

  // ── 莫兰迪背景色系（保留原有） ──
  static const Color bg = Color(0xFFE5DDD5);
  static const Color bgSecondary = Color(0xFFEDE7E0);
  static const Color card = Color(0xFFF9F6F2);
  static const Color cardHover = Color(0xFFF0EBE4);
  static const Color text = Color(0xFF3E3A37);
  static const Color textSecondary = Color(0xFF9B9590);
  static const Color textMuted = Color(0xFFBFB9B3);
  static const Color border = Color(0xFFD9D2CA);

  // ── 暗黑模式色板 ──
  static const Color darkBg = Color(0xFF1C1B1A);
  static const Color darkBgSecondary = Color(0xFF262422);
  static const Color darkCard = Color(0xFF2E2C2A);
  static const Color darkCardHover = Color(0xFF383634);
  static const Color darkText = Color(0xFFE8E4DF);
  static const Color darkTextSecondary = Color(0xFF9F9A94);
  static const Color darkTextMuted = Color(0xFF6B6662);
  static const Color darkBorder = Color(0xFF3E3A37);

  // ── 事件6色体系 ──
  /// 🔴 财报发布 — 红色系
  static const Color eventEarnings = Color(0xFFC97B6A);
  static const Color eventEarningsBg = Color(0xFFF5E8E4);

  /// 🟠 产品发布会 — 橙色系
  static const Color eventProduct = Color(0xFFD4946E);
  static const Color eventProductBg = Color(0xFFF6ECE2);

  /// 🔵 股东大会 — 蓝色系
  static const Color eventShareholder = Color(0xFF7B95A8);
  static const Color eventShareholderBg = Color(0xFFE4EBF0);

  /// 🟢 分红除权 — 绿色系
  static const Color eventDividend = Color(0xFF8AA88B);
  static const Color eventDividendBg = Color(0xFFE6EEE6);

  /// 🟣 IPO — 紫色系
  static const Color eventIPO = Color(0xFF9B8DB5);
  static const Color eventIPOBg = Color(0xFFEFEBF3);

  /// ⚪ 投资者会议/其他 — 灰色系
  static const Color eventInvestor = Color(0xFFB5B0A8);
  static const Color eventInvestorBg = Color(0xFFEFEDEA);
  static const Color eventOther = Color(0xFFB5B0A8);
  static const Color eventOtherBg = Color(0xFFEFEDEA);

  /// 按 EventType 索引的颜色列表
  static const List<Color> eventColors = [
    eventEarnings,
    eventShareholder,
    eventProduct,
    eventDividend,
    eventInvestor,
    eventIPO,
  ];

  /// 按 EventType 索引的背景色列表
  static const List<Color> eventBgColors = [
    eventEarningsBg,
    eventShareholderBg,
    eventProductBg,
    eventDividendBg,
    eventInvestorBg,
    eventIPOBg,
  ];

  // ── 股票头像颜色池（12色） ──
  static const List<Color> stockColors = [
    Color(0xFFC49B8A),
    Color(0xFFA8B5A2),
    Color(0xFF9BAEBF),
    Color(0xFFD4AF8D),
    Color(0xFFB8A5C0),
    Color(0xFFC4A882),
    Color(0xFF9BB5B0),
    Color(0xFFC2A0AE),
    Color(0xFFA898C0),
    Color(0xFFB0A090),
    Color(0xFFC8B8A8),
    Color(0xFFA0B0B8),
  ];

  // ── 事件过期状态色 ──
  static const Color eventPast = Color(0xFFB5B0A8);
  static const Color eventPastBg = Color(0xFFE8E5E2);
  static const Color eventPastText = Color(0xFFBFB9B3);

  // ── 交易日历色 ──
  static const Color tradingDayBorder = Color(0xFFD9D2CA);
  static const Color nonTradingDayBorder = Color(0xFFE5DDD5);
  static const Color holidayDot = Color(0xFFC49B8A);

  // ── 快捷别名 ──
  static const Color accent = eventEarnings;
  static const Color accent2 = eventShareholder;
}
