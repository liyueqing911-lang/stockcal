import '../../models/corporate_event.dart';
import '../../models/stock.dart';
import '../../core/constants.dart';

/// 内存缓存管理器
///
/// 在 SQLite 接入之前使用内存缓存。
/// Phase 2 后续将替换为 Drift 持久化存储。
class CacheManager {
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _eventCache = {};
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _stockCache = {};

  /// 获取缓存的事件
  Future<List<CorporateEvent>?> getEvents(String key) async {
    final entry = _eventCache[key];
    if (entry == null || entry.isExpired()) {
      _eventCache.remove(key);
      return null;
    }
    return entry.data
        .map((json) => CorporateEvent.fromJson(json))
        .toList();
  }

  /// 存入事件
  Future<void> putEvents(String key, List<CorporateEvent> events) async {
    _eventCache[key] = _CacheEntry(
      data: events.map((e) => e.toJson()).toList(),
      timestamp: DateTime.now(),
    );
  }

  /// 获取缓存的股票信息
  Future<List<Stock>?> getStocks(String key) async {
    final entry = _stockCache[key];
    if (entry == null || entry.isExpired()) {
      _stockCache.remove(key);
      return null;
    }
    // Return data as parsed stock info
    return null; // TODO: implement stock deserialization
  }

  /// 存入股票信息
  Future<void> putStocks(String key, List<Stock> stocks) async {
    _stockCache[key] = _CacheEntry(
      data: stocks.map((s) => s.toJson()).toList(),
      timestamp: DateTime.now(),
    );
  }

  /// 清除所有缓存
  void clear() {
    _eventCache.clear();
    _stockCache.clear();
  }

  /// 清除过期缓存
  void cleanExpired() {
    _eventCache.removeWhere((_, v) => v.isExpired());
    _stockCache.removeWhere((_, v) => v.isExpired());
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});

  bool isExpired() {
    final elapsed = DateTime.now().difference(timestamp).inMilliseconds;
    return elapsed > AppConstants.cacheTtlUS;
  }
}
