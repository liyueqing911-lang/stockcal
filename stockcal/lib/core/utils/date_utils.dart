import '../constants.dart';
import '../../models/market.dart';
import '../../models/trading_calendar.dart';

/// StockCal 日期工具扩展
class DateUtils {
  DateUtils._();

  /// 格式化日期为 yyyy-MM-dd
  static String fmtDate(DateTime d) {
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  /// 格式化日期为中文显示
  static String fmtDateCN(DateTime d) {
    return '${d.year}年${d.month}月${d.day}日';
  }

  /// 获取中文星期名
  static String weekdayCN(int weekday) {
    const labels = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return labels[weekday];
  }

  /// 判断两天是否为同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 判断是否为今天
  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  /// 判断事件是否已过期（日期已过）
  static bool isPast(DateTime eventDate) {
    final now = DateTime.now();
    return eventDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// 判断事件是否为今天
  static bool isEventToday(DateTime eventDate) {
    return isSameDay(eventDate, DateTime.now());
  }

  /// 判断事件是否为明天
  static bool isEventTomorrow(DateTime eventDate) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(eventDate, tomorrow);
  }

  /// 获取该月第一天
  static DateTime firstDayOfMonth(DateTime d) {
    return DateTime(d.year, d.month, 1);
  }

  /// 获取该月最后一天
  static DateTime lastDayOfMonth(DateTime d) {
    return DateTime(d.year, d.month + 1, 0);
  }

  /// 获取该月总天数
  static int daysInMonth(DateTime d) {
    return lastDayOfMonth(d).day;
  }

  /// 获取该月第一天是周几（周一=0，周日=6）
  static int firstWeekdayOfMonth(DateTime d) {
    final first = firstDayOfMonth(d);
    return (first.weekday + 6) % 7;
  }

  /// 获取季度
  static int quarter(DateTime d) => (d.month - 1) ~/ 3 + 1;

  /// 季度显示名称
  static String quarterLabel(DateTime d) {
    return 'Q${quarter(d)} (${d.month}月)';
  }

  /// 获取财报季时间范围（该季度 +/- 半个月缓冲）
  static (DateTime, DateTime) earningsSeasonRange(DateTime d) {
    final q = quarter(d);
    final startMonth = (q - 1) * 3 + 1;
    final endMonth = startMonth + 2;
    return (
      DateTime(d.year, startMonth, 1).subtract(const Duration(days: 15)),
      DateTime(d.year, endMonth + 1, 0).add(const Duration(days: 15)),
    );
  }

  /// 检测某天指定市场是否交易日
  static bool isTradingDay(DateTime date, Market market) {
    return TradingCalendarData.isTradingDay(date, market);
  }

  /// 获取数据缓存时效（按市场）
  static int cacheTtlForMarket(Market market) {
    switch (market) {
      case Market.us:
        return AppConstants.cacheTtlUS;
      case Market.hk:
        return AppConstants.cacheTtlHK;
      case Market.cn:
        return AppConstants.cacheTtlCN;
    }
  }

  /// 格式化相对时间（如「2小时前」「3天前」）
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}周前';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}个月前';
    return '${(diff.inDays / 365).floor()}年前';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
