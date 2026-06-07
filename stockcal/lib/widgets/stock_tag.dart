import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 股票标签组件
///
/// 用于帖子、事件详情中显示关联股票。
class StockTag extends StatelessWidget {
  final String symbol;
  final Color color;
  final bool removable;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const StockTag({
    super.key,
    required this.symbol,
    required this.color,
    this.removable = false,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 8,
          right: removable ? 4 : 8,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (removable) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 水平排列的股票标签列表
class StockTagRow extends StatelessWidget {
  final List<String> symbols;
  final Map<String, Color> colorMap;
  final bool removable;
  final void Function(String symbol)? onRemove;
  final void Function(String symbol)? onTap;

  const StockTagRow({
    super.key,
    required this.symbols,
    required this.colorMap,
    this.removable = false,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (symbols.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: symbols.map((sym) {
        final color = colorMap[sym] ?? AppColors.eventOther;
        return StockTag(
          symbol: sym,
          color: color,
          removable: removable,
          onRemove: onRemove != null ? () => onRemove!(sym) : null,
          onTap: onTap != null ? () => onTap!(sym) : null,
        );
      }).toList(),
    );
  }
}
