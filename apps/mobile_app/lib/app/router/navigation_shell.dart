import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/app/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// Application shell with Stitch-style bottom navigation.
///
/// Wraps [StatefulNavigationShell] which uses an [IndexedStack] to preserve
/// tab state and scroll positions across tab switches.
class NavigationShell extends StatelessWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_NavTab>[
    _NavTab(
      path: AppRoutes.home,
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavTab(
      path: AppRoutes.records,
      label: 'Records',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
    ),
    _NavTab(
      path: AppRoutes.upload,
      label: 'Upload',
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
    ),
    _NavTab(
      path: AppRoutes.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(NavigationShell._tabs.length, (index) {
              final tab = NavigationShell._tabs[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  isActive: isActive,
                  isDark: isDark,
                  onTap: () => onTabSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final _NavTab tab;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDark ? AppColors.primaryBright : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary;

    final icon = Icon(
      isActive ? tab.activeIcon : tab.icon,
      size: AppSpacing.iconSize,
      color: isActive ? activeColor : inactiveColor,
    );

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDark && isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkNavActivePill,
                borderRadius: AppRadius.radiusPill,
              ),
              child: icon,
            )
          else
            icon,
          const SizedBox(height: AppSpacing.xxs),
          Text(
            tab.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
