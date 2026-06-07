import 'package:flutter/material.dart';
import '../models/corporate_event.dart';

/// 事件类型彩色圆形标签
///
/// 用于日历格子和事件列表：
/// - 🔴 财报  🟠 产品发布会  🔵 股东大会
/// - 🟢 分红  🟣 IPO         ⚪ 投资者会议
///
/// 过期事件自动变灰。
class EventTypeTag extends StatelessWidget {
  final EventType type;
  final bool isPast;
  final double size;
  final bool showLabel;
  final bool showIcon;

  const EventTypeTag({
    super.key,
    required this.type,
    this.isPast = false,
    this.size = 10,
    this.showLabel = false,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPast ? type.pastColor : type.color;

    if (!showLabel) {
      // 仅显示圆点
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    // 显示图标 + 文字标签
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPast ? type.pastBgColor : type.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Text(type.icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            type.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
