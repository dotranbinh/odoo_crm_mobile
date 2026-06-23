import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/order.dart';

/// Pill status badge for sale orders, following design.md status tints.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({required this.status, this.compact = false, super.key});

  final OrderStatus status;
  final bool compact;

  static Color backgroundFor(OrderStatus status) => switch (status) {
        OrderStatus.draft => AppColors.statusNewBg,
        OrderStatus.sent => AppColors.statusQualifiedBg,
        OrderStatus.sale => AppColors.statusWonBg,
        OrderStatus.cancel => AppColors.statusLostBg,
      };

  static Color textColorFor(OrderStatus status) => switch (status) {
        OrderStatus.draft => AppColors.statusNewText,
        OrderStatus.sent => AppColors.statusQualifiedText,
        OrderStatus.sale => AppColors.statusWonText,
        OrderStatus.cancel => AppColors.statusLostText,
      };

  static String labelFor(OrderStatus status, AppLocalizations l10n) =>
      switch (status) {
        OrderStatus.draft => l10n.draft,
        OrderStatus.sent => l10n.sent,
        OrderStatus.sale => l10n.sale,
        OrderStatus.cancel => l10n.cancelled,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundFor(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        labelFor(status, l10n),
        style: (compact
                ? Theme.of(context).textTheme.labelSmall
                : Theme.of(context).textTheme.labelMedium)
            ?.copyWith(
          color: textColorFor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
