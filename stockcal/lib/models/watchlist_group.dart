/// 自选股分组模型
class WatchlistGroup {
  final String id;
  String name;
  int sortOrder;
  List<String> stockSymbols; // 该分组内的股票symbol列表

  WatchlistGroup({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    List<String>? stockSymbols,
  }) : stockSymbols = stockSymbols ?? [];

  /// 默认分组
  static WatchlistGroup defaultGroup() => WatchlistGroup(
        id: 'default',
        name: '全部',
        sortOrder: 0,
      );

  /// 预设分组模板
  static List<WatchlistGroup> presets() => [
        defaultGroup(),
        WatchlistGroup(id: 'tech', name: '科技股', sortOrder: 1),
        WatchlistGroup(id: 'dividend', name: '高股息', sortOrder: 2),
        WatchlistGroup(id: 'hk_connect', name: '港股通', sortOrder: 3),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sortOrder': sortOrder,
        'stockSymbols': stockSymbols,
      };

  factory WatchlistGroup.fromJson(Map<String, dynamic> json) =>
      WatchlistGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        sortOrder: json['sortOrder'] as int? ?? 0,
        stockSymbols: List<String>.from(json['stockSymbols'] ?? []),
      );
}
