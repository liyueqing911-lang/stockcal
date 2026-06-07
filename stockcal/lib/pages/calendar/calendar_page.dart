import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_state.dart';
import '../../models/corporate_event.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../widgets/event_card.dart';
import '../../widgets/event_detail_sheet.dart';
import '../../widgets/stock_search_sheet.dart';
import '../../widgets/event_type_tag.dart';
import 'week_view.dart';
import 'earning_season_view.dart';

/// 日历主页面 — 子Tab容器
///
/// 切换：月视图 / 周视图 / 财报季
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _subTab = 0; // 0=月 1=周 2=财报季

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(
          children: [
            // Header with month navigation + search
            _CalendarHeader(
              state: state,
              subTab: _subTab,
              onSubTabChanged: (i) => setState(() => _subTab = i),
            ),
            // Sub-tab content
            Expanded(
              child: IndexedStack(
                index: _subTab,
                children: [
                  _MonthViewContent(state: state),
                  const WeekView(),
                  const EarningSeasonView(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final AppState state;
  final int subTab;
  final ValueChanged<int> onSubTabChanged;

  const _CalendarHeader({
    required this.state,
    required this.subTab,
    required this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: month nav + search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _NavArrow(
                    icon: Icons.chevron_left,
                    onTap: () => state.goToPrevMonth(),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => state.goToToday(),
                    child: Text(
                      '${state.focusedMonth.year}年${state.focusedMonth.month}月',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _NavArrow(
                    icon: Icons.chevron_right,
                    onTap: () => state.goToNextMonth(),
                  ),
                ],
              ),
              Material(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(17),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () => showStockSearch(context),
                  child: const SizedBox(
                    width: 34, height: 34,
                    child: Icon(Icons.search, size: 18, color: AppColors.text),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Sub-tab selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Row(
            children: [
              _SubTabChip(
                label: '月视图',
                isActive: subTab == 0,
                onTap: () => onSubTabChanged(0),
              ),
              const SizedBox(width: 8),
              _SubTabChip(
                label: '周视图',
                isActive: subTab == 1,
                onTap: () => onSubTabChanged(1),
              ),
              const SizedBox(width: 8),
              _SubTabChip(
                label: '📊 财报季',
                isActive: subTab == 2,
                onTap: () => onSubTabChanged(2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubTabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.eventEarnings : AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

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

/// 月视图内容（从原 calendar_page 提取）
class _MonthViewContent extends StatelessWidget {
  final AppState state;
  const _MonthViewContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Weekday labels
        const _WeekdayRow(),
        // Calendar grid
        _MonthGrid(state: state),
        // Today button
        _TodayButton(state: state),
        // Event list for selected day
        Expanded(child: _EventListForDay(state: state)),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: days.map((d) => Expanded(
          child: Center(
            child: Text(d,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final AppState state;
  const _MonthGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: state.focusedMonth,
        selectedDayPredicate: (day) => du.DateUtils.isSameDay(day, state.selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          state.setSelectedDate(selectedDay);
          if (!du.DateUtils.isSameDay(focusedDay, state.focusedMonth)) {
            state.setFocusedMonth(focusedDay);
          }
        },
        onPageChanged: (focusedDay) {
          state.setFocusedMonth(focusedDay);
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        daysOfWeekVisible: false,
        headerVisible: false,
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: AppColors.eventEarnings,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          defaultTextStyle: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
            fontWeight: FontWeight.w400,
          ),
          outsideDaysVisible: true,
          outsideTextStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.35),
          ),
          weekendTextStyle: const TextStyle(color: AppColors.text),
          cellMargin: const EdgeInsets.all(1),
          markersMaxCount: 3,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final dayEvents = state.eventsForDay(day);
            if (dayEvents.isEmpty) return null;

            final typeSet = dayEvents.map((e) => e.type).toSet();

            return Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: typeSet.take(3).map((type) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: EventTypeTag(type: type, size: 7),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  final AppState state;
  const _TodayButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isToday = du.DateUtils.isToday(state.selectedDate);
    if (isToday) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => state.goToToday(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: const Text(
                '📍 今天',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.eventEarnings,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventListForDay extends StatelessWidget {
  final AppState state;
  const _EventListForDay({required this.state});

  @override
  Widget build(BuildContext context) {
    final dayEvents = state.eventsForDay(state.selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '${state.selectedDate.month}月${state.selectedDate.day}日 · ${du.DateUtils.weekdayCN(state.selectedDate.weekday)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: dayEvents.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📭', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 8),
                        Text('当天无事件', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                        Text('去搜索添加你关注的股票吧', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      final updatedEvent = CorporateEvent(
                        id: event.id,
                        stockSymbol: event.stockSymbol,
                        type: event.type,
                        date: event.date,
                        time: event.time,
                        timezone: event.timezone,
                        title: event.title,
                        description: event.description,
                        extraInfo: event.extraInfo,
                        status: CorporateEvent.calculateStatus(event.date),
                        isUserCreated: event.isUserCreated,
                      );
                      return EventCard(
                        event: updatedEvent,
                        stock: state.stockForSymbol(event.stockSymbol),
                        onTap: () => showEventDetail(context, updatedEvent),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
