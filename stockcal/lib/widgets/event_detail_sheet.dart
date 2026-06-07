import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/corporate_event.dart';
import '../providers/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_utils.dart' as du;

/// 显示事件详情 BottomSheet
void showEventDetail(BuildContext context, CorporateEvent event) {
  final state = context.read<AppState>();
  final stock = state.stockForSymbol(event.stockSymbol);
  final meta = event.type;
  final timeStr = event.fullTimezone ?? '全天事件';
  final isPast = event.isPast;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Container(
                width: 32, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Content
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                shrinkWrap: true,
                children: [
                  // Icon + Type
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isPast ? AppColors.eventPastBg : meta.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(meta.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        meta.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isPast ? AppColors.eventPastText : AppColors.text,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isPast) ...[
                        const SizedBox(width: 8),
                        const Text('✓ 已结束',
                          style: TextStyle(fontSize: 13, color: AppColors.eventPast),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stock info
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: stock?.color ?? meta.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.stockSymbol} · ${stock?.name ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date
                  _DetailRow(icon: '📅', text: '${event.date.year}/${event.date.month}/${event.date.day} · ${du.DateUtils.weekdayCN(event.date.weekday)}'),
                  // Time
                  _DetailRow(icon: '⏰', text: timeStr),
                  // Description
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    _DetailRow(icon: '📝', text: event.description!),
                  ],
                  // Extra info
                  if (event.extraInfo.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: event.extraInfo.entries.map((e) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${e.key}：${e.value}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eventEarnings,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('🔔 添加提醒'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        state.setSelectedDate(event.date);
                        state.setFocusedMonth(DateTime(event.date.year, event.date.month));
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.bgSecondary,
                        foregroundColor: AppColors.eventEarnings,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        side: BorderSide.none,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text('📊 查看 ${event.stockSymbol} 近期事件'),
                    ),
                  ),
                  // TODO Phase 5: 关联讨论入口
                  // const SizedBox(height: 8),
                  // _RelatedDiscussions(eventId: event.id),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  final String icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, child: Text(icon, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
