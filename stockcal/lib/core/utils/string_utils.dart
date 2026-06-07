/// StockCal 字符串处理工具
class StringUtils {
  StringUtils._();

  /// A股代码正则（6位数字，可能带SH/SZ前缀）
  static final RegExp _cnStockPattern = RegExp(
    r'(?:SH|SZ|sh|sz)?(\d{6})',
  );

  /// 美股代码正则（大写字母1-5位）
  static final RegExp _usStockPattern = RegExp(
    r'\b([A-Za-z]{1,5})\b',
  );

  /// 港股代码正则（4-5位数字，可能有.HK后缀）
  static final RegExp _hkStockPattern = RegExp(
    r'(\d{4,5})(?:\.HK|\.hk)?',
  );

  /// 从文本中提取股票代码
  ///
  /// 返回 [(code, market), ...]
  static List<(String, String)> extractStockCodes(String text) {
    final results = <(String, String)>[];

    // 先匹配 A股模式
    final cnMatches = _cnStockPattern.allMatches(text);
    for (final m in cnMatches) {
      results.add((m.group(1)!, 'CN'));
    }

    // 匹配港股模式
    final hkMatches = _hkStockPattern.allMatches(text);
    for (final m in hkMatches) {
      // 跳过已被A股匹配的
      final code = m.group(1)!;
      if (!results.any((r) => r.$1 == code)) {
        results.add((code, 'HK'));
      }
    }

    // 美股代码（最后匹配，避免误识别）
    if (results.isEmpty) {
      final usMatches = _usStockPattern.allMatches(text);
      for (final m in usMatches) {
        final code = m.group(1)!.toUpperCase();
        // 过滤掉常见英文单词
        if (!_isCommonWord(code) && code.length >= 2) {
          results.add((code, 'US'));
        }
      }
    }

    return results;
  }

  /// 是否是常见英文单词（美股代码过滤）
  static bool _isCommonWord(String word) {
    const commonWords = {
      'THE', 'AND', 'FOR', 'ARE', 'BUT', 'NOT', 'YOU', 'ALL',
      'CAN', 'HAD', 'HER', 'WAS', 'ONE', 'OUR', 'OUT', 'HAS',
      'HAVE', 'FROM', 'THEY', 'THIS', 'THAT', 'WITH', 'WILL',
      'YOUR', 'WHEN', 'WHAT', 'ABOUT', 'WOULD', 'THEIR',
      'INC', 'LTD', 'CORP', 'COM', 'NET', 'NEW', 'CEO',
    };
    return commonWords.contains(word.toUpperCase());
  }

  /// 判断是否为A股代码格式
  static bool isCnStockCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// 判断是否为港股代码格式
  static bool isHkStockCode(String code) {
    return RegExp(r'^\d{4,5}$').hasMatch(code);
  }

  /// 判断是否为美股代码格式
  static bool isUsStockCode(String code) {
    return RegExp(r'^[A-Za-z]{1,5}$').hasMatch(code);
  }

  /// 规范化股票代码
  static String normalizeCode(String code) {
    return code.toUpperCase().trim();
  }

  /// 为A股代码添加交易所前缀
  static String cnCodeWithExchange(String code) {
    if (code.startsWith('SH') || code.startsWith('SZ')) {
      return code.toUpperCase();
    }
    // 60xxxx 上交所，00/30xxxx 深交所
    if (code.startsWith('6')) return 'SH$code';
    return 'SZ$code';
  }
}
