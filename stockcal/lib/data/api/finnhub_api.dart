import '../../core/constants.dart';
import '../../models/corporate_event.dart';
import 'api_client.dart';

/// Finnhub API — 美股数据源
///
/// 免费额度：60 requests/min
/// 文档：https://finnhub.io/docs/api
class FinnhubApi {
  final ApiClient _client;
  final String _baseUrl = AppConstants.finnhubBaseUrl;
  final String _token = AppConstants.finnhubApiKey;

  FinnhubApi(this._client);

  Map<String, String> get _auth => {'token': _token};

  /// 获取财报日历
  ///
  /// 返回指定时间范围内的财报事件。
  /// [from] / [to] 格式 yyyy-MM-dd
  Future<List<Map<String, dynamic>>> getEarningsCalendar({
    required String from,
    required String to,
    String? symbol,
  }) async {
    final params = <String, dynamic>{
      ..._auth,
      'from': from,
      'to': to,
    };
    if (symbol != null) params['symbol'] = symbol;

    try {
      final response = await _client.get(
        '$_baseUrl/calendar/earnings',
        queryParameters: params,
      );
      final data = response['earningsCalendar'] as List? ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 获取 IPO 日历
  Future<List<Map<String, dynamic>>> getIpoCalendar({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _client.get(
        '$_baseUrl/calendar/ipo',
        queryParameters: {
          ..._auth,
          'from': from,
          'to': to,
        },
      );
      final data = response['ipoCalendar'] as List? ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 获取分红信息
  Future<List<Map<String, dynamic>>> getDividends({
    required String symbol,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _client.get(
        '$_baseUrl/stock/dividend',
        queryParameters: {
          ..._auth,
          'symbol': symbol,
          'from': from,
          'to': to,
        },
      );
      return (response['data'] as List? ?? []).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 按公司搜索股票
  Future<List<Map<String, dynamic>>> searchStock(String query) async {
    try {
      final response = await _client.get(
        '$_baseUrl/search',
        queryParameters: {
          ..._auth,
          'q': query,
        },
      );
      final results = response['result'] as List? ?? [];
      return results
          .where((r) => r['type'] == 'Common Stock')
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 将 Finnhub 数据转换为 CorporateEvent
  List<CorporateEvent> toCorporateEvents(List<Map<String, dynamic>> raw) {
    final events = <CorporateEvent>[];
    int id = DateTime.now().millisecondsSinceEpoch;

    for (final item in raw) {
      final dateStr = item['date'] as String?;
      if (dateStr == null) continue;

      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      events.add(CorporateEvent(
        id: id++,
        stockSymbol: (item['symbol'] as String?)?.toUpperCase() ?? '',
        type: EventType.earnings,
        date: date,
        title: '${item['symbol'] ?? ''} 财报发布',
        description: 'Q${(date.month - 1) ~/ 3 + 1} 财报',
        extraInfo: {
          if (item['epsEstimate'] != null)
            '预期EPS': '${item['epsEstimate']}',
          if (item['revenueEstimate'] != null)
            '预期营收': '${item['revenueEstimate']}',
        },
        status: CorporateEvent.calculateStatus(date),
      ));
    }
    return events;
  }

  /// IPO 转为事件
  List<CorporateEvent> ipoToEvents(List<Map<String, dynamic>> raw) {
    final events = <CorporateEvent>[];
    int id = DateTime.now().millisecondsSinceEpoch + 1000;

    for (final item in raw) {
      final dateStr = item['date'] as String?;
      if (dateStr == null) continue;

      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      events.add(CorporateEvent(
        id: id++,
        stockSymbol: (item['symbol'] as String?)?.toUpperCase() ?? '',
        type: EventType.ipo,
        date: date,
        title: '${item['name'] ?? item['symbol']} IPO',
        description: '${item['exchange'] ?? ''} 上市',
        extraInfo: {
          if (item['price'] != null) '发行价': '${item['price']}',
          if (item['numberOfShares'] != null)
            '发行数量': '${item['numberOfShares']}',
        },
        status: CorporateEvent.calculateStatus(date),
      ));
    }
    return events;
  }
}
