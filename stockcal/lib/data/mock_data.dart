import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/corporate_event.dart';
import '../models/market.dart';
import '../core/theme/app_colors.dart';

/// 模拟数据（开发环境使用）
///
/// 生产环境通过 [StockRepository] 和 [EventRepository] 从 API 获取。
class MockData {
  MockData._();

  static List<Stock> stocks = [
    Stock(symbol: 'AAPL', name: 'Apple Inc.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[0], following: true),
    Stock(symbol: 'TSLA', name: 'Tesla Inc.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[1], following: true),
    Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[2], following: true),
    Stock(symbol: 'MSFT', name: 'Microsoft Corp.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[3], following: true),
    Stock(symbol: 'NVDA', name: 'NVIDIA Corp.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[4], following: true),
    Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[5], following: false),
    Stock(symbol: 'META', name: 'Meta Platforms', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[6], following: false),
    Stock(symbol: 'AMD', name: 'Advanced Micro Devices', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[7], following: false),
    Stock(symbol: 'INTC', name: 'Intel Corporation', exchange: 'NASDAQ', market: Market.us, color: AppColors.stockColors[8], following: false),
    Stock(symbol: 'BABA', name: 'Alibaba Group', exchange: 'NYSE', market: Market.us, color: AppColors.stockColors[9], following: false),
    Stock(symbol: '600519', name: '贵州茅台', exchange: '上交所', market: Market.cn, color: AppColors.stockColors[10], following: false),
    Stock(symbol: '0700', name: '腾讯控股', exchange: '港交所', market: Market.hk, color: AppColors.stockColors[11], following: false),
    Stock(symbol: '300750', name: '宁德时代', exchange: '深交所', market: Market.cn, color: AppColors.stockColors[0], following: false),
    Stock(symbol: '9988', name: '阿里巴巴-SW', exchange: '港交所', market: Market.hk, color: AppColors.stockColors[1], following: false),
  ];

  static List<CorporateEvent> events = [
    CorporateEvent(id: 1, stockSymbol: 'AAPL', type: EventType.earnings, date: DateTime(2026, 6, 15), time: const TimeOfDay(hour: 16, minute: 30), timezone: '美东', title: 'Q3 财报发布', description: '苹果第三季度财报发布', extraInfo: {'预期EPS': '\$2.35', '预期营收': '\$95.2B', '上季EPS': '\$2.28'}),
    CorporateEvent(id: 2, stockSymbol: 'TSLA', type: EventType.shareholder, date: DateTime(2026, 6, 20), time: const TimeOfDay(hour: 10, minute: 0), timezone: '美东', title: '年度股东大会', description: '投票表决多项重要议案', extraInfo: {'地点': 'Austin, TX', '直播': 'ir.tesla.com'}),
    CorporateEvent(id: 3, stockSymbol: 'GOOGL', type: EventType.product, date: DateTime(2026, 6, 18), time: const TimeOfDay(hour: 13, minute: 0), timezone: '美东', title: 'Google I/O', description: '年度开发者大会主题演讲', extraInfo: {'地点': 'Mountain View', '焦点': 'AI新功能'}),
    CorporateEvent(id: 4, stockSymbol: 'MSFT', type: EventType.dividend, date: DateTime(2026, 6, 10), title: '分红除权日', description: '微软季度分红除权', extraInfo: {'每股分红': '\$0.83', '股息率': '0.7%'}),
    CorporateEvent(id: 5, stockSymbol: 'NVDA', type: EventType.earnings, date: DateTime(2026, 6, 22), time: const TimeOfDay(hour: 16, minute: 20), timezone: '美东', title: 'Q1 财报发布', description: '市场高度关注AI芯片业务增长', extraInfo: {'预期EPS': '\$6.88', '预期营收': '\$38.5B'}),
    CorporateEvent(id: 6, stockSymbol: 'AMZN', type: EventType.investor, date: DateTime(2026, 6, 5), time: const TimeOfDay(hour: 9, minute: 0), timezone: '美东', title: '投资者日', description: '管理层介绍云计算与AI战略', extraInfo: {'地点': 'Seattle', '主题': 'AI战略'}),
    CorporateEvent(id: 7, stockSymbol: 'META', type: EventType.product, date: DateTime(2026, 6, 25), time: const TimeOfDay(hour: 10, minute: 0), timezone: '美东', title: 'Meta Connect', description: '预计发布新VR/AR产品', extraInfo: {'地点': 'Menlo Park', '焦点': 'Quest 4'}),
    CorporateEvent(id: 8, stockSymbol: 'AAPL', type: EventType.product, date: DateTime(2026, 6, 3), time: const TimeOfDay(hour: 10, minute: 0), timezone: '美东', title: 'WWDC 2026', description: '苹果全球开发者大会', extraInfo: {'地点': 'Apple Park', '焦点': 'iOS 20, AI'}),
    CorporateEvent(id: 9, stockSymbol: 'TSLA', type: EventType.product, date: DateTime(2026, 6, 12), time: const TimeOfDay(hour: 14, minute: 0), timezone: '美东', title: '新车型交付仪式', description: '新车型首批交付活动', extraInfo: {'地点': 'Fremont, CA'}),
    CorporateEvent(id: 10, stockSymbol: 'MSFT', type: EventType.earnings, date: DateTime(2026, 6, 28), time: const TimeOfDay(hour: 16, minute: 0), timezone: '美东', title: 'Q4 财报发布', description: '微软第四季度财报', extraInfo: {'预期EPS': '\$3.20', '预期营收': '\$68.5B'}),
    CorporateEvent(id: 11, stockSymbol: 'GOOGL', type: EventType.dividend, date: DateTime(2026, 6, 8), title: '分红除权日', description: 'Alphabet 季度分红除权', extraInfo: {'每股分红': '\$0.25', '股息率': '0.5%'}),
    CorporateEvent(id: 12, stockSymbol: 'NVDA', type: EventType.investor, date: DateTime(2026, 6, 14), time: const TimeOfDay(hour: 11, minute: 0), timezone: '美东', title: '分析师日', description: '投资者关系分析师会议'),
    CorporateEvent(id: 13, stockSymbol: 'TSLA', type: EventType.earnings, date: DateTime(2026, 6, 30), time: const TimeOfDay(hour: 16, minute: 30), timezone: '美东', title: 'Q2 财报发布', description: '特斯拉第二季度财报', extraInfo: {'预期EPS': '\$0.85', '预期营收': '\$26.8B'}),
    CorporateEvent(id: 14, stockSymbol: 'AAPL', type: EventType.dividend, date: DateTime(2026, 6, 24), title: '分红除权日', description: '苹果季度分红除权', extraInfo: {'每股分红': '\$0.26', '股息率': '0.4%'}),
    CorporateEvent(id: 15, stockSymbol: '600519', type: EventType.dividend, date: DateTime(2026, 6, 18), title: '分红除权日', description: '贵州茅台2025年度分红除权', extraInfo: {'每股分红': '¥25.91', '股息率': '1.5%'}),
    CorporateEvent(id: 16, stockSymbol: '0700', type: EventType.earnings, date: DateTime(2026, 6, 12), time: const TimeOfDay(hour: 16, minute: 0), timezone: 'HKT', title: 'Q1 财报发布', description: '腾讯控股第一季度财报', extraInfo: {'预期EPS': 'HK\$5.80', '预期营收': 'HK\$168B'}),
  ];

  /// Feed 动态数据（模拟）
  static List<Map<String, dynamic>> feedItems = [
    {'symbol': 'AAPL', 'type': 'product', 'title': 'WWDC 2026 主题演讲将于6月3日举行', 'desc': '苹果公司确认WWDC 2026将于6月3日在Apple Park举行，预计将发布iOS 20和多项AI新功能。', 'time': '2小时前'},
    {'symbol': 'NVDA', 'type': 'earnings', 'title': '英伟达Q1财报预期大幅上调', 'desc': '多家投行上调英伟达Q1营收预期至\$38.5B，AI芯片需求持续强劲，数据中心业务有望再创新高。', 'time': '5小时前'},
    {'symbol': 'TSLA', 'type': 'product', 'title': '特斯拉新车型交付活动定档6月12日', 'desc': '特斯拉宣布将于6月12日在Fremont工厂举行新车型首批交付仪式，马斯克将出席。', 'time': '昨天'},
    {'symbol': 'MSFT', 'type': 'dividend', 'title': '微软宣布维持季度分红\$0.83/股', 'desc': '微软董事会批准维持每股\$0.83的季度分红，除权日为6月10日。', 'time': '昨天'},
    {'symbol': 'GOOGL', 'type': 'product', 'title': 'Google I/O 2026 议程公布', 'desc': 'Google公布I/O大会议程，AI和云计算成为焦点，Gemini新版本即将亮相。', 'time': '2天前'},
    {'symbol': 'AAPL', 'type': 'earnings', 'title': '苹果Q3财报预期：市场看好服务业务增长', 'desc': '分析师预计苹果Q3服务业务收入将同比增长15%，成为新的增长引擎。', 'time': '3天前'},
    {'symbol': '600519', 'type': 'dividend', 'title': '贵州茅台公布2025年度分红方案', 'desc': '贵州茅台公告每股分红25.91元，除权日为6月18日，股息率约1.5%。', 'time': '1天前'},
    {'symbol': '0700', 'type': 'earnings', 'title': '腾讯Q1财报前瞻：游戏业务复苏受关注', 'desc': '市场预计腾讯Q1营收约1680亿港元，游戏和广告业务有望实现双位数增长。', 'time': '4小时前'},
  ];
}
