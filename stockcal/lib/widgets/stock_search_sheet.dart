import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/market.dart';
import '../core/theme/app_colors.dart';

/// 显示股票搜索弹窗
void showStockSearch(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _StockSearchContent(),
  );
}

class _StockSearchContent extends StatefulWidget {
  const _StockSearchContent();

  @override
  State<_StockSearchContent> createState() => _StockSearchContentState();
}

class _StockSearchContentState extends State<_StockSearchContent> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allStocks = state.stocks;
    final filtered = _query.isEmpty
        ? allStocks
        : allStocks.where((s) =>
            s.symbol.toLowerCase().contains(_query.toLowerCase()) ||
            s.name.toLowerCase().contains(_query.toLowerCase())).toList();

    const hotSymbols = ['AAPL', 'TSLA', 'GOOGL', 'MSFT', 'NVDA', 'AMZN', 'META', '600519', '0700'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 32, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                            decoration: const InputDecoration(
                              hintText: '搜索股票代码或名称...',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('取消',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.eventEarnings,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Hot tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('热门关注',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hotSymbols.map((sym) {
                    final stock = state.stockForSymbol(sym);
                    final isFollowing = stock?.following ?? false;
                    return GestureDetector(
                      onTap: () {
                        state.toggleFollow(sym);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                        decoration: BoxDecoration(
                          color: isFollowing ? AppColors.eventShareholder : AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isFollowing ? AppColors.eventShareholder : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '$sym ${isFollowing ? "✓" : "+"}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isFollowing ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(
                height: 0.5, color: AppColors.border, indent: 20, endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final s = filtered[index];
                return Material(
                  color: AppColors.card,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(s.symbol,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(s.market.flag, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    subtitle: Text('${s.name} · ${s.exchange}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        state.toggleFollow(s.symbol);
                        setState(() {});
                      },
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: s.following ? AppColors.eventShareholder : AppColors.eventEarnings,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.following ? '✓' : '+',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      state.toggleFollow(s.symbol);
                      setState(() {});
                    },
                  ),
                );
            },
          ), // ListView.separated
        ), // Expanded
      ],
    ),
  );
}
}
