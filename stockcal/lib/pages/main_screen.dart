import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../core/theme/app_colors.dart';
import 'calendar/calendar_page.dart';
import 'watchlist/watchlist_page.dart';
import 'feed_page.dart'; // 暂时保留，Phase 5 替换
import 'profile/profile_page.dart';

/// 主屏幕 — 底部Tab容器
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: state.currentTab,
              children: const [
                CalendarPage(),
                WatchlistPage(),
                FeedPage(), // Phase 5 替换为 DiscoverPage
                ProfilePage(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TabItem(
                      icon: Icons.calendar_today,
                      label: '日历',
                      isActive: state.currentTab == 0,
                      onTap: () => state.setCurrentTab(0),
                    ),
                    _TabItem(
                      icon: Icons.star_border,
                      label: '自选股',
                      isActive: state.currentTab == 1,
                      onTap: () => state.setCurrentTab(1),
                    ),
                    _TabItem(
                      icon: Icons.explore_outlined,
                      label: '发现',
                      isActive: state.currentTab == 2,
                      onTap: () => state.setCurrentTab(2),
                    ),
                    _TabItem(
                      icon: Icons.person_outline,
                      label: '我的',
                      isActive: state.currentTab == 3,
                      onTap: () => state.setCurrentTab(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
