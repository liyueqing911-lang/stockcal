import '../../models/corporate_event.dart';
import '../../models/stock.dart';
import '../../models/market.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_colors.dart';
import '../local/cache_manager.dart';
import 'finnhub_api.dart';
import 'eastmoney_api.dart';
import 'yahoo_api.dart';

/// API 聚合层
///
/// 按市场路由请求，统一数据格式，管理缓存策略。
class ApiAggregator {
  final FinnhubApi finnhub;
  final EastmoneyApi eastmoney;
  final YahooApi yahoo;
  final CacheManager cache;

  ApiAggregator({
    required this.finnhub,
    required this.eastmoney,
    required this.yahoo,
    required this.cache,
  });

  /// 获取某市场某月的事件
  Future<List<CorporateEvent>> fetchEvents({
    required Market market,
    required DateTime month,
    List<String>? symbols,
  }) async {
    final from = DateUtils.fmtDate(DateUtils.firstDayOfMonth(month));
    final to = DateUtils.fmtDate(DateUtils.lastDayOfMonth(month));
    final cacheKey = 'events_${market.name}_${from}_$to';

    // 检查缓存
    final cached = await cache.getEvents(cacheKey);
    if (cached != null) return cached;

    List<CorporateEvent> events;

    switch (market) {
      case Market.us:
        events = await _fetchUsEvents(from, to, symbols);
      case Market.cn:
        events = await _fetchCnEvents(from, to);
      case Market.hk:
        events = await _fetchHkEvents(from, to, symbols);
    }

    // 写入缓存
    await cache.putEvents(cacheKey, events);
    return events;
  }

  /// 美股事件
  Future<List<CorporateEvent>> _fetchUsEvents(
    String from,
    String to,
    List<String>? symbols,
  ) async {
    final events = <CorporateEvent>[];

    // 获取关注股票的财报
    if (symbols != null && symbols.isNotEmpty) {
      for (final sym in symbols) {
        final raw = await finnhub.getEarningsCalendar(
          from: from,
          to: to,
          symbol: sym,
        );
        events.addAll(finnhub.toCorporateEvents(raw));
      }
    } else {
      final raw = await finnhub.getEarningsCalendar(from: from, to: to);
      events.addAll(finnhub.toCorporateEvents(raw));
    }

    // 获取 IPO
    final ipoRaw = await finnhub.getIpoCalendar(from: from, to: to);
    events.addAll(finnhub.ipoToEvents(ipoRaw));

    // 分拆出分红事件
    if (symbols != null) {
      for (final sym in symbols) {
        final divs = await finnhub.getDividends(
          symbol: sym,
          from: from,
          to: to,
        );
        // Finnhub 分红返回的格式不同，需要单独处理
        int id = DateTime.now().millisecondsSinceEpoch + 5000;
        for (final d in divs) {
          final payDate = d['payDate'] as String?;
          if (payDate != null) {
            final date = DateTime.tryParse(payDate);
            if (date != null) {
              events.add(CorporateEvent(
                id: id++,
                stockSymbol: sym,
                type: EventType.dividend,
                date: date,
                title: '$sym 分红支付日',
                description: '分红支付',
                extraInfo: {
                  if (d['amount'] != null) '每股分红': '\$${d['amount']}',
                },
                status: CorporateEvent.calculateStatus(date),
              ));
            }
          }
        }
      }
    }

    return events;
  }

  /// A股事件
  Future<List<CorporateEvent>> _fetchCnEvents(
    String from,
    String to,
  ) async {
    final events = <CorporateEvent>[];

    // 财报预约
    final earningsRaw = await eastmoney.getEarningsCalendar(from: from, to: to);
    events.addAll(eastmoney.toEarningsEvents(earningsRaw));

    // 除权除息
    final dividendRaw = await eastmoney.getDividendCalendar(from: from, to: to);
    events.addAll(eastmoney.toDividendEvents(dividendRaw));

    return events;
  }

  /// 港股事件（主要通过 Yahoo Finance）
  Future<List<CorporateEvent>> _fetchHkEvents(
    String from,
    String to,
    List<String>? symbols,
  ) async {
    final events = <CorporateEvent>[];

    if (symbols != null) {
      for (final sym in symbols) {
        try {
          final divs = await yahoo.getDividendHistory(sym);
          events.addAll(yahoo.dividendsToEvents(sym, divs));
        } catch (_) {
          // 忽略单个股票的错误
        }
      }
    }

    return events;
  }

  /// 搜索股票（跨市场）
  Future<List<Stock>> searchStocks(String query) async {
    final results = <Stock>[];

    // 美股搜索
    try {
      final usResults = await yahoo.search(query);
      results.addAll(yahoo.searchToStocks(usResults));
    } catch (_) {}

    // A股搜索
    try {
      final cnResults = await eastmoney.searchStock(query);
      for (var i = 0; i < cnResults.length && i < 12; i++) {
        final r = cnResults[i];
        final code = r['Code'] as String? ?? '';
        final name = r['Name'] as String? ?? '';
        if (code.isEmpty) continue;

        results.add(Stock(
          symbol: code,
          name: name,
          exchange: code.startsWith('6') ? '上交所' : '深交所',
          market: Market.cn,
          color: AppColors.stockColors[i % AppColors.stockColors.length],
        ));
      }
    } catch (_) {}

    return results;
  }

  /// 获取股票价格
  Future<double?> getStockPrice(String symbol, Market market) async {
    try {
      return await yahoo.getPrice(symbol);
    } catch (_) {
      return null;
    }
  }
}
