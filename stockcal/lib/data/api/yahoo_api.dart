import '../../core/constants.dart';
import '../../models/corporate_event.dart';
import '../../models/stock.dart';
import '../../models/market.dart';
import '../../core/theme/app_colors.dart';
import 'api_client.dart';

/// Yahoo Finance 非官方 API
///
/// 用于港股数据补全、美股价格查询。
/// 注意：此 API 非官方，可能不稳定。
class YahooApi {
  final ApiClient _client;
  static const String _baseUrl = AppConstants.yahooFinanceBaseUrl;

  YahooApi(this._client);

  /// 获取股票基本信息
  Future<Map<String, dynamic>?> getQuoteSummary(String symbol) async {
    try {
      final response = await _client.get(
        '$_baseUrl/v11/finance/quoteSummary/$symbol',
        queryParameters: {
          'modules': 'price,summaryDetail,defaultKeyStatistics',
        },
      );
      final result = response['quoteSummary'];
      if (result == null || result['result'] == null) return null;
      final items = result['result'] as List?;
      return items?.isNotEmpty == true ? items!.first as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
  }

  /// 获取历史分红数据
  Future<List<Map<String, dynamic>>> getDividendHistory(String symbol) async {
    try {
      final response = await _client.get(
        '$_baseUrl/v8/finance/chart/$symbol',
        queryParameters: {
          'range': '1y',
          'interval': '1d',
          'events': 'div',
        },
      );
      final chart = response['chart'];
      if (chart == null || chart['result'] == null) return [];
      final result = (chart['result'] as List).first as Map<String, dynamic>;
      final dividends = result['events']?['dividends'] as Map<String, dynamic>?;
      if (dividends == null) return [];

      return dividends.entries.map((e) {
        final data = e.value as Map<String, dynamic>;
        return {
          'date': DateTime.fromMillisecondsSinceEpoch(
            (data['date'] as num).toInt() * 1000,
          ).toIso8601String().substring(0, 10),
          'amount': data['amount'],
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// 获取股票价格
  Future<double?> getPrice(String symbol) async {
    try {
      final response = await _client.get(
        '$_baseUrl/v8/finance/chart/$symbol',
        queryParameters: {
          'range': '1d',
          'interval': '1m',
        },
      );
      final chart = response['chart'];
      if (chart == null || chart['result'] == null) return null;
      final result = (chart['result'] as List).first as Map<String, dynamic>;
      final meta = result['meta'] as Map<String, dynamic>?;
      return meta?['regularMarketPrice']?.toDouble();
    } catch (_) {
      return null;
    }
  }

  /// 搜股
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await _client.get(
        '$_baseUrl/v1/finance/search',
        queryParameters: {'q': query, 'quotesCount': '20'},
      );
      return (response['quotes'] as List? ?? [])
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 分红转为事件
  List<CorporateEvent> dividendsToEvents(
    String symbol,
    List<Map<String, dynamic>> dividends,
  ) {
    final events = <CorporateEvent>[];
    int id = DateTime.now().millisecondsSinceEpoch + 4000;

    for (final div in dividends) {
      final dateStr = div['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      events.add(CorporateEvent(
        id: id++,
        stockSymbol: symbol,
        type: EventType.dividend,
        date: date,
        title: '$symbol 分红除权日',
        description: '分红除权',
        extraInfo: {
          if (div['amount'] != null) '每股分红': '\$${div['amount']}',
        },
        status: CorporateEvent.calculateStatus(date),
      ));
    }
    return events;
  }

  /// 搜索结果为 Stock 模型
  List<Stock> searchToStocks(List<Map<String, dynamic>> results) {
    final stocks = <Stock>[];
    for (var i = 0; i < results.length && i < AppColors.stockColors.length; i++) {
      final r = results[i];
      final symbol = r['symbol'] as String? ?? '';
      if (symbol.isEmpty) continue;

      stocks.add(Stock(
        symbol: symbol,
        name: r['longname'] as String? ?? r['shortname'] as String? ?? symbol,
        exchange: r['exchange'] as String? ?? '',
        market: Market.us, // Yahoo 主要返回美股
        color: AppColors.stockColors[i % AppColors.stockColors.length],
      ));
    }
    return stocks;
  }
}
