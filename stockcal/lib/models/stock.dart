import 'package:flutter/material.dart';
import 'market.dart';

/// 股票模型
class Stock {
  final String symbol;
  final String name;
  String exchange;
  final Market market;
  Color color;
  bool following;
  String groupId; // 所属分组的ID

  Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.market,
    required this.color,
    this.following = false,
    this.groupId = 'default',
  });

  /// 股票简称缩写（前2字符）
  String get initials => symbol.length >= 2 ? symbol.substring(0, 2) : symbol;

  /// 带国旗的市场显示
  String get marketDisplay => '${market.flag} $exchange';

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'exchange': exchange,
        'market': market.name,
        'color': color.value.toRadixString(16),
        'following': following,
        'groupId': groupId,
      };

  /// 从 JSON 反序列化（简化版，color 需外部注入）
  factory Stock.fromJson(Map<String, dynamic> json, Color fallbackColor) {
    return Stock(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      exchange: json['exchange'] as String? ?? '',
      market: Market.values.firstWhere(
        (m) => m.name == json['market'],
        orElse: () => Market.us,
      ),
      color: fallbackColor,
      following: json['following'] as bool? ?? false,
      groupId: json['groupId'] as String? ?? 'default',
    );
  }
}
