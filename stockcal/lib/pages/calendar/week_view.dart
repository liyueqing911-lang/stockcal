import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/corporate_event.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../widgets/event_card.dart';
import '../../widgets/event_detail_sheet.dart';
import '../../widgets/event_type_tag.dart';
import '../../widgets/empty_state.dart';

/// 周视图组件
///
/// 水平滑动切换周，显示7天的事件概览。
class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // 计算当前周的起止日期
        final weekStart = _getWeekStart(state.selectedDate);
        final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

        return Column(
          children: [
            // 周切换条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: () {
                      final prev = state.selectedDate.subtract(const Duration(days: 7));
                      state.setSelectedDate(prev);
                      state.setFocusedMonth(DateTime(prev.year, prev.month));
                    },
                  ),
                  Text(
                    '${du.DateUtils.fmtDate(weekStart)} — ${du.DateUtils.fmtDate(days.last)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: () {
                      final next = state.selectedDate.add(const Duration(days: 7));
                      state.setSelectedDate(next);
                      state.setFocusedMonth(DateTime(next.year, next.month));
                    },
                  ),
                ],
              ),
            ),
            // 7天列
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final dayEvents = state.eventsForDay(day);
                  final isToday = du.DateUtils.isToday(day);
                  final isSelected =
                      du.DateUtils.isSameDay(day, state.selectedDate);

                  return GestureDetector(
                    onTap: () => state.setSelectedDate(day),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.card
                            : (isToday ? AppColors.eventEarningsBg : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.eventEarnings.withValues(alpha: 0.3))
                            : null,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          // 日期栏
                          SizedBox(
                            width: 48,
                            child: Column(
                              children: [
                                Text(
                                  du.DateUtils.weekdayCN(day.weekday),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isToday ? AppColors.eventEarnings : AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${day.month}/${day.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isToday ? AppColors.eventEarnings : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 事件区
                          Expanded(
                            child: dayEvents.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      '无事件',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: dayEvents.take(3).map((e) {
                                      final isPast = e.date.isBefore(DateTime.now());
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: InkWell(
                                          onTap: () => showEventDetail(context, e),
                                          child: Row(
                                            children: [
                                              EventTypeTag(type: e.type, size: 7, isPast: isPast),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${e.stockSymbol} ${e.title}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isPast ? AppColors.eventPastText : AppColors.text,
                                                    decoration: isPast ? TextDecoration.lineThrough : null,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    ),
                          ),
                          if (dayEvents.length > 3)
                            Text(
                              '+${dayEvents.length - 3}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          width: 30, height: 30,
          child: Icon(icon, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}
