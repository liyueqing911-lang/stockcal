/// StockCal 全局常量配置
class AppConstants {
  AppConstants._();

  // ── API Keys（生产环境应从安全存储读取） ──
  static const String finnhubApiKey = String.fromEnvironment(
    'FINNHUB_API_KEY',
    defaultValue: 'demo',
  );

  // ── API Endpoints ──
  static const String finnhubBaseUrl = 'https://finnhub.io/api/v1';
  static const String eastmoneyBaseUrl = 'https://push2.eastmoney.com';
  static const String eastmoneySearchUrl = 'https://searchapi.eastmoney.com';
  static const String yahooFinanceBaseUrl = 'https://query1.finance.yahoo.com';

  // ── 缓存策略（毫秒） ──
  static const int cacheTtlUS = 6 * 60 * 60 * 1000; // 美股 6h
  static const int cacheTtlHK = 6 * 60 * 60 * 1000; // 港股 6h
  static const int cacheTtlCN = 2 * 60 * 60 * 1000; // A股 2h
  static const int cacheTtlStockInfo = 24 * 60 * 60 * 1000; // 股票基本信息 24h
  static const int cacheTtlNews = 30 * 60 * 1000; // 资讯 30min

  // ── 后台任务间隔 ──
  static const int backgroundRefreshHours = 6;

  // ── 提醒时间 ──
  static const int reminderDayBeforeHour = 20; // T-1 天 20:00
  static const int reminderDayBeforeMinute = 0;
  static const int reminderDayOfHour = 8; // T 天 08:00
  static const int reminderDayOfMinute = 0;

  // ── API 请求 ──
  static const Duration requestTimeout = Duration(seconds: 15);
  static const int maxRetries = 2;

  // ── 搜索 ──
  static const int searchDebounceMs = 300;
  static const int searchMinChars = 2;

  // ── 分页 ──
  static const int communityPageSize = 20;
  static const int eventListPageSize = 50;

  // ── 热门股票（搜索页快捷标签） ──
  static const List<String> hotSymbols = [
    'AAPL', 'TSLA', 'GOOGL', 'MSFT', 'NVDA',
    'AMZN', 'META', 'AMD', 'BABA', '0700',
    '600519', '000858', '300750', '601318',
  ];

  // ── 市场货币 ──
  static const Map<String, String> marketCurrency = {
    'US': 'USD',
    'CN': 'CNY',
    'HK': 'HKD',
  };
}
