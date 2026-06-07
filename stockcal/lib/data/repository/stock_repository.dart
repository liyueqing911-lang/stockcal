import '../../models/stock.dart';
import '../../models/market.dart';
import '../api/api_aggregator.dart';

/// 股票数据仓库
class StockRepository {
  final ApiAggregator _api;

  StockRepository({required ApiAggregator api}) : _api = api;

  /// 搜索股票（跨市场）
  Future<List<Stock>> search(String query) async {
    return _api.searchStocks(query);
  }

  /// 获取股票价格
  Future<double?> getPrice(String symbol, Market market) async {
    return _api.getStockPrice(symbol, market);
  }

  /// 获取股票信息（搜索+富化）
  Future<Stock?> enrichStock(Stock stock) async {
    // 尝试从 Yahoo 获取更完整的股票信息
    // 目前返回原有数据
    return stock;
  }
}
