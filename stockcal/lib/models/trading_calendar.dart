import 'market.dart';

/// 交易日历条目
///
/// 用于标记某一天是否为交易日。
/// 非交易日包括周末和法定节假日。
class TradingDay {
  final DateTime date;
  final Market market;
  final bool isTradingDay;
  final String? holidayName; // 节假日名称（如「国庆节」）

  const TradingDay({
    required this.date,
    required this.market,
    required this.isTradingDay,
    this.holidayName,
  });

  /// 是否是非交易日的节假日（非周末）
  bool get isHoliday => !isTradingDay && date.weekday <= 5;

  /// 是否是周末
  bool get isWeekend => date.weekday >= 6;

  @override
  bool operator ==(Object other) =>
      other is TradingDay &&
      other.date.year == date.year &&
      other.date.month == date.month &&
      other.date.day == date.day &&
      other.market == market;

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        market,
      );
}

/// A股节假日数据（静态，可后续接入API）
///
/// 目前包含主要长假。生产环境可通过东方财富API获取完整数据。
class TradingCalendarData {
  TradingCalendarData._();

  /// 2026年 A股主要休市日期（需每年更新）
  static final Set<DateTime> _cnHolidays2026 = {
    // 元旦
    DateTime(2026, 1, 1),
    DateTime(2026, 1, 2),
    // 春节（2026年2月17日除夕）
    DateTime(2026, 2, 16),
    DateTime(2026, 2, 17),
    DateTime(2026, 2, 18),
    DateTime(2026, 2, 19),
    DateTime(2026, 2, 20),
    DateTime(2026, 2, 21),
    DateTime(2026, 2, 22),
    // 清明节
    DateTime(2026, 4, 5),
    DateTime(2026, 4, 6),
    // 劳动节
    DateTime(2026, 5, 1),
    DateTime(2026, 5, 2),
    DateTime(2026, 5, 3),
    DateTime(2026, 5, 4),
    DateTime(2026, 5, 5),
    // 端午节
    DateTime(2026, 5, 30),
    DateTime(2026, 5, 31),
    DateTime(2026, 6, 1),
    // 中秋节+国庆节
    DateTime(2026, 10, 1),
    DateTime(2026, 10, 2),
    DateTime(2026, 10, 3),
    DateTime(2026, 10, 4),
    DateTime(2026, 10, 5),
    DateTime(2026, 10, 6),
    DateTime(2026, 10, 7),
    DateTime(2026, 10, 8),
  };

  /// 检查 A股 是否为交易日
  static bool isCnTradingDay(DateTime date) {
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return false;
    }
    final normalized = DateTime(date.year, date.month, date.day);
    return !_cnHolidays2026.contains(normalized);
  }

  /// 检查美股是否为交易日
  static bool isUsTradingDay(DateTime date) {
    // 美股周末休市
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return false;
    }
    // TODO: 补充美股主要节假日（独立日、感恩节、圣诞节等）
    return true;
  }

  /// 检查港股是否为交易日
  static bool isHkTradingDay(DateTime date) {
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return false;
    }
    // TODO: 补充港股主要节假日
    return true;
  }

  /// 按市场检查交易日
  static bool isTradingDay(DateTime date, Market market) {
    switch (market) {
      case Market.cn:
        return isCnTradingDay(date);
      case Market.us:
        return isUsTradingDay(date);
      case Market.hk:
        return isHkTradingDay(date);
    }
  }
}
