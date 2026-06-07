import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/corporate_event.dart';
import '../../models/market.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/stock_search_sheet.dart';
import '../../widgets/empty_state.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final following = state.followingStocks;
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '自选股',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      // 导入按钮 (Phase 4 完善)
                      Material(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(17),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            // TODO Phase 4: 导入自选股
                          },
                          child: const SizedBox(
                            width: 34, height: 34,
                            child: Icon(Icons.file_download_outlined,
                                size: 18, color: AppColors.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(17),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () => showStockSearch(context),
                          child: const SizedBox(
                            width: 34, height: 34,
                            child: Icon(Icons.add, size: 20, color: AppColors.text),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '共关注 ${following.length} 只股票',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: following.isEmpty
                  ? EmptyState(
                      icon: '⭐',
                      title: '还没有关注的股票',
                      subtitle: '点击右上角 + 添加你关注的股票',
                      actionLabel: '去搜索',
                      onAction: () => showStockSearch(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: following.length,
                      itemBuilder: (context, index) {
                        final stock = following[index];
                        final nextEvent = state.nextEventForStock(stock.symbol);
                        final eventCount = state.events
                            .where((e) => e.stockSymbol == stock.symbol)
                            .length;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                if (nextEvent != null) {
                                  state.setSelectedDate(nextEvent.date);
                                  state.setFocusedMonth(DateTime(
                                    nextEvent.date.year,
                                    nextEvent.date.month,
                                  ));
                                }
                                state.setCurrentTab(0);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: stock.color,
                                        borderRadius: BorderRadius.circular(21),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        stock.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(stock.symbol,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.text,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(stock.market.flag,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            nextEvent != null
                                                ? '${nextEvent.type.icon} ${nextEvent.title} · ${nextEvent.date.month}/${nextEvent.date.day}'
                                                : '暂无近期事件',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgSecondary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$eventCount 事件',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}
