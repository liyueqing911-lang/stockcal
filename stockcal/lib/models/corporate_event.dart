import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 事件状态
enum EventStatus {
  /// 未到期
  upcoming,

  /// 今天
  today,

  /// 已过期
  past,
}

/// 事件类型
enum EventType {
  earnings, // 🔴 财报发布
  shareholder, // 🔵 股东大会
  product, // 🟠 产品发布会
  dividend, // 🟢 分红除权
  investor, // ⚪ 投资者会议
  ipo, // 🟣 IPO
  other, // ⚪ 其他

  /// 用户手动添加的自定义事件
  custom,
}

extension EventTypeMeta on EventType {
  /// 中文名称
  String get label {
    switch (this) {
      case EventType.earnings:
        return '财报发布';
      case EventType.shareholder:
        return '股东大会';
      case EventType.product:
        return '产品发布会';
      case EventType.dividend:
        return '分红除权';
      case EventType.investor:
        return '投资者会议';
      case EventType.ipo:
        return 'IPO';
      case EventType.other:
        return '其他事件';
      case EventType.custom:
        return '自定义';
    }
  }

  /// 图标
  String get icon {
    switch (this) {
      case EventType.earnings:
        return '📊';
      case EventType.shareholder:
        return '👥';
      case EventType.product:
        return '🚀';
      case EventType.dividend:
        return '💰';
      case EventType.investor:
        return '🎤';
      case EventType.ipo:
        return '🏛️';
      case EventType.other:
        return '📌';
      case EventType.custom:
        return '🔔';
    }
  }

  /// 事件颜色（从 AppColors 事件色系获取）
  Color get color {
    switch (this) {
      case EventType.earnings:
        return AppColors.eventEarnings;
      case EventType.shareholder:
        return AppColors.eventShareholder;
      case EventType.product:
        return AppColors.eventProduct;
      case EventType.dividend:
        return AppColors.eventDividend;
      case EventType.investor:
        return AppColors.eventInvestor;
      case EventType.ipo:
        return AppColors.eventIPO;
      case EventType.other:
        return AppColors.eventOther;
      case EventType.custom:
        return AppColors.eventOther;
    }
  }

  /// 背景色
  Color get bgColor {
    switch (this) {
      case EventType.earnings:
        return AppColors.eventEarningsBg;
      case EventType.shareholder:
        return AppColors.eventShareholderBg;
      case EventType.product:
        return AppColors.eventProductBg;
      case EventType.dividend:
        return AppColors.eventDividendBg;
      case EventType.investor:
        return AppColors.eventInvestorBg;
      case EventType.ipo:
        return AppColors.eventIPOBg;
      case EventType.other:
        return AppColors.eventOtherBg;
      case EventType.custom:
        return AppColors.eventOtherBg;
    }
  }

  /// 过期状态下使用的颜色
  Color get pastColor => AppColors.eventPast;

  Color get pastBgColor => AppColors.eventPastBg;
}

/// 公司事件模型
class CorporateEvent {
  final int id;
  final String stockSymbol;
  final EventType type;
  final DateTime date;
  final TimeOfDay? time;
  final String? timezone;
  final String title;
  final String? description;
  final Map<String, String> extraInfo;
  final EventStatus status;
  final bool isUserCreated; // 是否为用户手动添加

  CorporateEvent({
    required this.id,
    required this.stockSymbol,
    required this.type,
    required this.date,
    this.time,
    this.timezone,
    required this.title,
    this.description,
    this.extraInfo = const {},
    this.status = EventStatus.upcoming,
    this.isUserCreated = false,
  });

  /// 时间字符串
  String get timeString => time != null
      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
      : '全天';

  /// 完整时区信息
  String? get fullTimezone => timezone != null && time != null
      ? '$timeString ($timezone)'
      : (time != null ? timeString : null);

  /// 事件是否已过期
  bool get isPast => status == EventStatus.past;

  /// 事件是否为今天
  bool get isToday => status == EventStatus.today;

  /// 获取当前合适的显示颜色（过期则返回灰色）
  Color displayColor() {
    return isPast ? type.pastColor : type.color;
  }

  /// 获取当前合适的背景色
  Color displayBgColor() {
    return isPast ? type.pastBgColor : type.bgColor;
  }

  /// 计算事件状态（基于当前时间）
  static EventStatus calculateStatus(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (eventDay.isBefore(today)) return EventStatus.past;
    if (eventDay == today) return EventStatus.today;
    return EventStatus.upcoming;
  }

  /// 序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'stockSymbol': stockSymbol,
        'type': type.name,
        'date': date.toIso8601String(),
        'time': time != null
            ? '${time!.hour}:${time!.minute}'
            : null,
        'timezone': timezone,
        'title': title,
        'description': description,
        'extraInfo': extraInfo,
        'status': status.name,
        'isUserCreated': isUserCreated,
      };

  /// 反序列化
  factory CorporateEvent.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['time'] != null) {
      final parts = (json['time'] as String).split(':');
      time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return CorporateEvent(
      id: json['id'] as int,
      stockSymbol: json['stockSymbol'] as String,
      type: EventType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EventType.other,
      ),
      date: DateTime.parse(json['date'] as String),
      time: time,
      timezone: json['timezone'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      extraInfo: Map<String, String>.from(json['extraInfo'] ?? {}),
      status: EventStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      isUserCreated: json['isUserCreated'] as bool? ?? false,
    );
  }
}
