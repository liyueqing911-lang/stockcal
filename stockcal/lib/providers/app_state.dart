import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/corporate_event.dart';
import '../models/market.dart';
import '../data/mock_data.dart';

/// 全局应用状态
///
/// 管理股票列表、事件列表、日历导航、Tab切换。
/// Phase 2 将接入真实数据替换 MockData。
class AppState extends ChangeNotifier {
  List<Stock> _stocks = List.from(MockData.stocks);
  List<CorporateEvent> _events = List.from(MockData.events);
  DateTime _selectedDate = DateTime(2026, 6, 7);
  DateTime _focusedMonth = DateTime(2026, 6);
  int _currentTab = 0;

  // ── Getters ──

  List<Stock> get stocks => _stocks;
  List<Stock> get followingStocks =>
      _stocks.where((s) => s.following).toList();
  List<CorporateEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  int get currentTab => _currentTab;

  /// 按市场筛选股票
  List<Stock> stocksByMarket(Market market) =>
      _stocks.where((s) => s.market == market).toList();

  /// 某天的事件列表
  List<CorporateEvent> eventsForDay(DateTime day) {
    return _events
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList()
      ..sort((a, b) {
        // 先按时间排序，无时间的排最后
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        return a.time!.hour.compareTo(b.time!.hour);
      });
  }

  /// 某天的股票symbol列表（用于日历标记）
  List<String> stockSymbolsForDay(DateTime day) {
    return eventsForDay(day).map((e) => e.stockSymbol).toSet().toList();
  }

  /// 按symbol查股票
  Stock? stockForSymbol(String symbol) {
    try {
      return _stocks.firstWhere((s) => s.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  /// 股票的下一个事件
  CorporateEvent? nextEventForStock(String symbol) {
    final now = DateTime(2026, 6, 1);
    final stockEvents = _events
        .where((e) => e.stockSymbol == symbol && e.date.isAfter(now))
        .toList();
    stockEvents.sort((a, b) => a.date.compareTo(b.date));
    return stockEvents.isNotEmpty ? stockEvents.first : null;
  }

  /// 按类型过滤事件
  List<CorporateEvent> filteredEvents({EventType? type}) {
    if (type == null) return _events;
    return _events.where((e) => e.type == type).toList();
  }

  // ── Actions ──

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedMonth(DateTime month) {
    _focusedMonth = month;
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  void goToPrevMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void goToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _focusedMonth = DateTime(today.year, today.month);
    notifyListeners();
  }

  void toggleFollow(String symbol) {
    final stock = stockForSymbol(symbol);
    if (stock != null) {
      stock.following = !stock.following;
      notifyListeners();
    }
  }

  void setCurrentTab(int index) {
    _currentTab = index;
    notifyListeners();
  }
}
