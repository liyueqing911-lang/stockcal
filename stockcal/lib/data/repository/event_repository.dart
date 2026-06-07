import '../../models/corporate_event.dart';
import '../../models/market.dart';
import '../api/api_aggregator.dart';
import '../local/cache_manager.dart';

/// 事件数据仓库
///
/// 协调 API 和本地缓存，对上层 Provider 提供统一接口。
class EventRepository {
  final ApiAggregator _api;
  final CacheManager _cache;

  EventRepository({required ApiAggregator api, required CacheManager cache})
      : _api = api,
        _cache = cache;

  /// 获取某月事件（自动区分市场）
  Future<List<CorporateEvent>> getEventsForMonth({
    required Market market,
    required DateTime month,
    List<String>? symbols,
  }) async {
    return _api.fetchEvents(
      market: market,
      month: month,
      symbols: symbols,
    );
  }

  /// 获取多市场事件（合并）
  Future<List<CorporateEvent>> getAllMarketEvents({
    required DateTime month,
    required List<String> usSymbols,
    required List<String> cnSymbols,
    required List<String> hkSymbols,
  }) async {
    final results = <CorporateEvent>[];

    // 并行请求各市场（伪并行，Dart 单线程）
    if (usSymbols.isNotEmpty) {
      final usEvents = await _api.fetchEvents(
        market: Market.us,
        month: month,
        symbols: usSymbols,
      );
      results.addAll(usEvents);
    }

    if (cnSymbols.isNotEmpty) {
      final cnEvents = await _api.fetchEvents(
        market: Market.cn,
        month: month,
      );
      results.addAll(cnEvents);
    }

    if (hkSymbols.isNotEmpty) {
      final hkEvents = await _api.fetchEvents(
        market: Market.hk,
        month: month,
        symbols: hkSymbols,
      );
      results.addAll(hkEvents);
    }

    return results;
  }

  /// 清除所有缓存
  void clearCache() => _cache.clear();
}
