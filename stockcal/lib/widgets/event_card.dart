import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/corporate_event.dart';
import '../core/theme/app_colors.dart';

/// 事件卡片组件
///
/// 在日历事件列表中展示，支持过期状态视觉（灰色+删除线）。
class EventCard extends StatelessWidget {
  final CorporateEvent event;
  final Stock? stock;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeMeta = event.type;
    final isPast = event.isPast;
    final dotColor = isPast ? AppColors.eventPast : (stock?.color ?? typeMeta.color);
    final titleColor = isPast ? AppColors.eventPastText : AppColors.text;
    final subtitleColor = isPast ? AppColors.eventPastText : AppColors.textSecondary;
    final timeColor = isPast ? AppColors.eventPastText : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 6色圆点
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // 事件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${typeMeta.icon} ${event.stockSymbol} · ${event.title}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (stock != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            stock!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 时间 + 状态标记
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      event.timeString,
                      style: TextStyle(
                        fontSize: 12,
                        color: timeColor,
                      ),
                    ),
                    if (isPast)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '✓',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.eventPast,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
