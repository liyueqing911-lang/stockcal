/// 股票交易市场
enum Market {
  /// 🇺🇸 美股（NASDAQ / NYSE）
  us,

  /// 🇨🇳 A股（上交所 / 深交所）
  cn,

  /// 🇭🇰 港股（港交所）
  hk,
}

extension MarketMeta on Market {
  /// 显示名称
  String get label {
    switch (this) {
      case Market.us:
        return '美股';
      case Market.cn:
        return 'A股';
      case Market.hk:
        return '港股';
    }
  }

  /// 国旗图标
  String get flag {
    switch (this) {
      case Market.us:
        return '🇺🇸';
      case Market.cn:
        return '🇨🇳';
      case Market.hk:
        return '🇭🇰';
    }
  }

  /// 货币
  String get currency {
    switch (this) {
      case Market.us:
        return 'USD';
      case Market.cn:
        return 'CNY';
      case Market.hk:
        return 'HKD';
    }
  }

  /// 货币符号
  String get currencySymbol {
    switch (this) {
      case Market.us:
        return '\$';
      case Market.cn:
        return '¥';
      case Market.hk:
        return 'HK\$';
    }
  }

  /// 开盘时间（当地时间）
  String get tradingHours {
    switch (this) {
      case Market.us:
        return '09:30-16:00 ET';
      case Market.cn:
        return '09:30-15:00 CST';
      case Market.hk:
        return '09:30-16:00 HKT';
    }
  }
}
