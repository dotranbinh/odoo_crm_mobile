import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleAction(
          icon: Icons.person_add_outlined,
          label: l10n.newLeadAction,
          onTap: () => context.push(AppRoutes.createLead),
        ),
        _CircleAction(
          icon: Icons.shopping_bag_outlined,
          label: l10n.newOrderAction,
          onTap: () => context.go(AppRoutes.orders),
        ),
        _CircleAction(
          icon: Icons.search,
          label: l10n.searchAction,
          onTap: () => context.go(AppRoutes.leads),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _buttonSize = 52.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_buttonSize),
        child: SizedBox(
          width: 88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryTintLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
