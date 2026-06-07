import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/corporate_event.dart';
import '../../models/market.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;

/// 财报季时间轴视图
///
/// 按季度展示关注股票的财报密集度。
/// 支持横向滑动切换季度。
class EarningSeasonView extends StatefulWidget {
  const EarningSeasonView({super.key});

  @override
  State<EarningSeasonView> createState() => _EarningSeasonViewState();
}

class _EarningSeasonViewState extends State<EarningSeasonView> {
  late DateTime _currentQuarter;

  @override
  void initState() {
    super.initState();
    _currentQuarter = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final year = _currentQuarter.year;
        final q = du.DateUtils.quarter(_currentQuarter);

        // 收集该季度有财报的关注股票
        final earningsEvents = state.events.where((e) {
          final eq = du.DateUtils.quarter(e.date);
          return e.date.year == year && eq == q && e.type == EventType.earnings;
        }).toList();

        // 按周分组
        final weekMap = <int, List<CorporateEvent>>{};
        for (final e in earningsEvents) {
          final week = _weekOfMonth(e.date);
          weekMap.putIfAbsent(week, () => []).add(e);
        }

        // 热力图数据
        final maxEvents = weekMap.values.fold<int>(0, (max, list) => list.length > max ? list.length : max);

        return Column(
          children: [
            // 季度切换
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SeasonNavBtn(
                    icon: Icons.chevron_left,
                    onTap: () => setState(() {
                      _currentQuarter = DateTime(year, (q - 1) * 3 + 1 - 2);
                    }),
                  ),
                  Column(
                    children: [
                      Text(
                        '$year年 Q$q',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '${earningsEvents.length} 份财报',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _SeasonNavBtn(
                    icon: Icons.chevron_right,
                    onTap: () => setState(() {
                      _currentQuarter = DateTime(year, q * 3 + 1);
                    }),
                  ),
                ],
              ),
            ),
            // 热力图
            if (earningsEvents.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📊', style: TextStyle(fontSize: 36)),
                      SizedBox(height: 8),
                      Text('本季度暂无财报事件',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // 热力图条
                    const SizedBox(height: 8),
                    Text(
                      '财报密集度',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    _HeatmapBar(
                      weekMap: weekMap,
                      maxEvents: maxEvents,
                      year: year,
                      quarter: q,
                    ),
                    const SizedBox(height: 20),
                    // 事件列表
                    Text(
                      '事件列表',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    ...earningsEvents.map((e) {
                      final st = state.stockForSymbol(e.stockSymbol);
                      final isPast = e.date.isBefore(DateTime.now());
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: isPast ? AppColors.eventPast : AppColors.eventEarnings,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e.stockSymbol} · ${e.title}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isPast ? AppColors.eventPastText : AppColors.text,
                                      decoration: isPast ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text(
                                    '${du.DateUtils.fmtDateCN(e.date)}${st != null ? ' · ${st.name}' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPast)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.eventPastBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('已发布', style: TextStyle(fontSize: 11, color: AppColors.eventPast)),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  int _weekOfMonth(DateTime date) {
    return ((date.day - 1) ~/ 7) + 1;
  }
}

class _SeasonNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SeasonNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: const SizedBox(
          width: 36, height: 36,
          child: Icon(Icons.chevron_left, size: 20),
        ),
      ),
    );
  }
}

/// 热力图组件
class _HeatmapBar extends StatelessWidget {
  final Map<int, List<CorporateEvent>> weekMap;
  final int maxEvents;
  final int year;
  final int quarter;

  const _HeatmapBar({
    required this.weekMap,
    required this.maxEvents,
    required this.year,
    required this.quarter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(5, (week) {
          final events = weekMap[week + 1] ?? [];
          final intensity = maxEvents > 0 ? events.length / maxEvents : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    'W${week + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: intensity.clamp(0.05, 1.0),
                      backgroundColor: AppColors.bgSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          AppColors.eventEarningsBg,
                          AppColors.eventEarnings,
                          intensity,
                        )!,
                      ),
                      minHeight: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${events.length}只',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: intensity > 0.5 ? AppColors.eventEarnings : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
