import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.shell,
    super.key,
  });

  final StatefulNavigationShell shell;

  void _onTabTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: shell,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createLead),
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: l10n.dashboard,
              selected: shell.currentIndex == 0,
              onTap: () => _onTabTap(0),
            ),
            _NavItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: l10n.leads,
              selected: shell.currentIndex == 1,
              onTap: () => _onTabTap(1),
            ),
            const SizedBox(width: AppSizes.fabSize),
            _NavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag,
              label: l10n.orders,
              selected: shell.currentIndex == 2,
              onTap: () => _onTabTap(2),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: l10n.profile,
              selected: shell.currentIndex == 3,
              onTap: () => _onTabTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                height: 3,
                width: 24,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
