import '../../core/constants.dart';
import '../../models/corporate_event.dart';
import 'api_client.dart';

/// 东方财富 API — A股数据源
///
/// 免费、无需 API Key。
/// 提供财报预约、除权除息、股票基本信息。
class EastmoneyApi {
  final ApiClient _client;
  static const String _baseUrl = AppConstants.eastmoneyBaseUrl;

  EastmoneyApi(this._client);

  /// 获取A股财报预约日历
  ///
  /// 返回指定日期范围内的财报披露预约。
  Future<List<Map<String, dynamic>>> getEarningsCalendar({
    required String from,
    required String to,
  }) async {
    // 东方财富 API：报表披露计划
    try {
      final response = await _client.get(
        '$_baseUrl/api/qt/clist/get',
        queryParameters: {
          'pn': '1',
          'pz': '200',
          'po': '1',
          'np': '1',
          'fltt': '2',
          'invt': '2',
          'fid': 'f3',
          'fs': 'm:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23',
          'fields': 'f12,f14,f3,f2,f15,f16,f17,f18',
        },
      );

      final data = response['data'];
      if (data == null || data['diff'] == null) return [];

      final items = (data['diff'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return items;
    } catch (_) {
      return [];
    }
  }

  /// 获取A股除权除息日历
  Future<List<Map<String, dynamic>>> getDividendCalendar({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _client.get(
        '$_baseUrl/api/qt/clist/get',
        queryParameters: {
          'pn': '1',
          'pz': '200',
          'po': '1',
          'np': '1',
          'fltt': '2',
          'invt': '2',
          'fid': 'f3',
          // 除权除息筛选条件
          'fs': 'm:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23,b:DLBZ04',
          'fields': 'f12,f14,f3,f2,f15,f16,f17,f18',
        },
      );

      final data = response['data'];
      if (data == null || data['diff'] == null) return [];

      return (data['diff'] as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 搜索A股股票
  Future<List<Map<String, dynamic>>> searchStock(String keyword) async {
    try {
      final response = await _client.get(
        'https://searchapi.eastmoney.com/api/suggest/get',
        queryParameters: {
          'input': keyword,
          'type': '14',
          'token': 'D43BF722C8E33BDC906FB84D85E326E8',
          'count': '20',
        },
      );

      final data = response['QuotationCodeTable'];
      if (data == null || data['Data'] == null) return [];

      return (data['Data'] as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// 将东方财富数据转为 CorporateEvent (财报)
  List<CorporateEvent> toEarningsEvents(List<Map<String, dynamic>> raw) {
    final events = <CorporateEvent>[];
    int id = DateTime.now().millisecondsSinceEpoch + 2000;

    for (final item in raw) {
      final code = item['f12'] as String?; // 股票代码
      final name = item['f14'] as String?; // 股票简称
      if (code == null) continue;

      events.add(CorporateEvent(
        id: id++,
        stockSymbol: code,
        type: EventType.earnings,
        date: DateTime.now(), // TODO: 从数据中解析具体日期
        title: '$name 财报披露',
        description: '${name ?? code} 定期报告披露',
        extraInfo: {
          if (item['f17'] != null) '报告期': '${item['f17']}',
          if (item['f18'] != null) '预约日期': '${item['f18']}',
        },
        status: EventStatus.upcoming,
      ));
    }
    return events;
  }

  /// 将东方财富数据转为 CorporateEvent (除权除息)
  List<CorporateEvent> toDividendEvents(List<Map<String, dynamic>> raw) {
    final events = <CorporateEvent>[];
    int id = DateTime.now().millisecondsSinceEpoch + 3000;

    for (final item in raw) {
      final code = item['f12'] as String?;
      final name = item['f14'] as String?;
      if (code == null) continue;

      events.add(CorporateEvent(
        id: id++,
        stockSymbol: code,
        type: EventType.dividend,
        date: DateTime.now(), // TODO: 从数据中解析
        title: '$name 除权除息',
        description: '$code 分红除权除息日',
        extraInfo: {
          if (item['f15'] != null) '每股分红': '¥${item['f15']}',
          if (item['f16'] != null) '除权日': '${item['f16']}',
        },
        status: EventStatus.upcoming,
      ));
    }
    return events;
  }
}
