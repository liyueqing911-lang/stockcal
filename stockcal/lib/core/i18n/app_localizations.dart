import 'package:flutter/material.dart';

/// StockCal 国际化委托
///
/// 当前仅支持简体中文，架构已预留扩展空间。
/// 添加新语言步骤：
/// 1. 创建 `xx_yy.dart` 实现同一套 getter
/// 2. 在 `localizationsDelegates` 中注册
/// 3. 在 `supportedLocales` 中添加
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// 当前实例
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// 委托列表
  static final List<LocalizationsDelegate<dynamic>> delegates = [
    _ZhCNDelegate(),
  ];

  /// 支持的语言
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
  ];

  // ── 通用 ──
  String get appTitle => 'StockCal';
  String get appSubtitle => '炒股日历';
  String get ok => '确定';
  String get cancel => '取消';
  String get confirm => '确认';
  String get save => '保存';
  String get delete => '删除';
  String get edit => '编辑';
  String get search => '搜索';
  String get loading => '加载中...';
  String get noData => '暂无数据';
  String get noEvents => '当天无事件';
  String get retry => '重试';
  String get networkError => '网络连接失败';
  String get dataSource => '数据来源';
  String get updatedAt => '更新于';

  // ── Tab标签 ──
  String get tabCalendar => '日历';
  String get tabWatchlist => '自选股';
  String get tabDiscover => '发现';
  String get tabProfile => '我的';

  // ── 日历 ──
  String get today => '今天';
  String get monthView => '月视图';
  String get weekView => '周视图';
  String get earningsSeason => '财报季';
  String get addReminder => '添加提醒';
  String get viewStockEvents => '查看近期事件';

  // ── 事件类型 ──
  String get eventEarnings => '财报发布';
  String get eventShareholder => '股东大会';
  String get eventProduct => '产品发布会';
  String get eventDividend => '分红除权';
  String get eventInvestor => '投资者会议';
  String get eventIPO => 'IPO';
  String get eventOther => '其他事件';

  // ── 自选股 ──
  String get following => '关注';
  String get unfollow => '取消关注';
  String get importWatchlist => '导入自选股';
  String get importFromFile => '从文件导入';
  String get importFromClipboard => '从剪贴板导入';
  String get matchedCount => '已匹配';
  String get unmatchedCount => '未找到';
  String get stockGroup => '分组';
  String get noFollowing => '还没有关注的股票';
  String get noFollowingHint => '去搜索添加你关注的股票吧';

  // ── 发现 ──
  String get subTabFollowing => '关注';
  String get subTabHot => '热门';
  String get subTabEarnings => '财报季';
  String get subTabDiscussion => '讨论';
  String get createPost => '发帖';
  String get postTypeAnalysis => '财报解读';
  String get postTypeDiscussion => '讨论';
  String get postTypeQuestion => '提问';
  String get postTypeNews => '资讯分享';
  String get postTypePrediction => '预测';
  String get relatedStocks => '关联股票';
  String get relatedEvent => '关联事件';
  String get comments => '评论';
  String get like => '点赞';
  String get share => '分享';
  String get hotTopics => '热议话题';

  // ── 通知 ──
  String get notificationSettings => '提醒设置';
  String get earningsReminder => '财报提醒';
  String get shareholderReminder => '股东大会提醒';
  String get productReminder => '产品发布提醒';
  String get dividendReminder => '分红除权提醒';
  String get ipoReminder => 'IPO提醒';
  String get reminderDayBefore => 'T-1 天 20:00 提醒';
  String get reminderDayOf => '当天 08:00 提醒';

  // ── 设置 ──
  String get settings => '设置';
  String get appearance => '外观';
  String get darkMode => '暗黑模式';
  String get lightMode => '浅色模式';
  String get defaultView => '默认视图';
  String get about => '关于 StockCal';
  String get version => '版本';
  String get language => '语言';
}

/// 简体中文代理
class _ZhCNDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _ZhCNDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
