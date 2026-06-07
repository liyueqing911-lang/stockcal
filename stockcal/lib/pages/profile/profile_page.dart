import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../providers/theme_state.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool earningsOn = true;
  bool shareholderOn = true;
  bool productOn = true;
  bool dividendOn = true;
  bool ipoOn = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final themeState = context.watch<ThemeState>();
    final followingCount = state.followingStocks.length;
    final eventCount = state.events.length;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '我的',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 8),
            children: [
              // Profile card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.eventEarnings,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        alignment: Alignment.center,
                        child: const Text('📈', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(height: 12),
                      const Text('投资者',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '关注 $followingCount 只股票 · 本月 $eventCount 个事件',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 提醒设置
              _SettingsGroup(
                children: [
                  _ToggleRow(
                    icon: '📊',
                    label: '财报提醒',
                    value: earningsOn,
                    onChanged: (v) => setState(() => earningsOn = v),
                  ),
                  _ToggleRow(
                    icon: '👥',
                    label: '股东大会提醒',
                    value: shareholderOn,
                    onChanged: (v) => setState(() => shareholderOn = v),
                  ),
                  _ToggleRow(
                    icon: '🚀',
                    label: '产品发布提醒',
                    value: productOn,
                    onChanged: (v) => setState(() => productOn = v),
                  ),
                  _ToggleRow(
                    icon: '💰',
                    label: '分红除权提醒',
                    value: dividendOn,
                    onChanged: (v) => setState(() => dividendOn = v),
                  ),
                  _ToggleRow(
                    icon: '🏛️',
                    label: 'IPO提醒',
                    value: ipoOn,
                    onChanged: (v) => setState(() => ipoOn = v),
                  ),
                ],
              ),

              // 外观设置
              _SettingsGroup(
                children: [
                  _NavRow(
                    icon: '🌙',
                    label: '暗黑模式',
                    trailing: Switch(
                      value: themeState.isDark,
                      onChanged: (v) => themeState.setDarkMode(v),
                      activeColor: AppColors.eventEarnings,
                    ),
                  ),
                ],
              ),

              // 通用设置
              _SettingsGroup(
                children: [
                  _NavRow(label: '默认视图', value: '月视图'),
                  _NavRow(label: '数据来源', value: '模拟数据'),
                  _NavRow(label: '关于 StockCal', value: 'v1.0.0'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$icon  $label',
              style: const TextStyle(fontSize: 15, color: AppColors.text),
            ),
            GestureDetector(
              onTap: () => onChanged(!value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48, height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: value ? AppColors.eventShareholder : AppColors.border,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 24, height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? icon;
  final Widget? trailing;

  const _NavRow({
    required this.label,
    this.value,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Text(icon!, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                ],
                Text(label,
                  style: const TextStyle(fontSize: 15, color: AppColors.text),
                ),
              ],
            ),
            trailing ??
                Text(
                  value ?? '',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
          ],
        ),
      ),
    );
  }
}
