import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/corporate_event.dart';
import '../data/mock_data.dart';
import '../core/theme/app_colors.dart';

/// 动态页 (临时保留，Phase 5 替换为 DiscoverPage)
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final feedItems = MockData.feedItems;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                '动态',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              final item = feedItems[index];
              final symbol = item['symbol'] as String;
              final stock = state.stockForSymbol(symbol);
              final typeStr = item['type'] as String;
              final eventType = _parseEventType(typeStr);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final relatedEvent = state.events
                          .where((e) => e.stockSymbol == symbol && e.type == eventType)
                          .firstOrNull;
                      if (relatedEvent != null) {
                        state.setSelectedDate(relatedEvent.date);
                        state.setFocusedMonth(DateTime(
                          relatedEvent.date.year,
                          relatedEvent.date.month,
                        ));
                        state.setCurrentTab(0);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: stock?.color ?? AppColors.eventOther,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(symbol,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(item['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: eventType.bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${eventType.icon} ${eventType.label}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: eventType.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(item['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(item['desc'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
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
  }

  EventType _parseEventType(String type) {
    switch (type) {
      case 'earnings': return EventType.earnings;
      case 'shareholder': return EventType.shareholder;
      case 'product': return EventType.product;
      case 'dividend': return EventType.dividend;
      case 'investor': return EventType.investor;
      default: return EventType.other;
    }
  }
}
