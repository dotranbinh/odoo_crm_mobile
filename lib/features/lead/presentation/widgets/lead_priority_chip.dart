import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/lead.dart';

class LeadPriorityChip extends StatelessWidget {
  const LeadPriorityChip({required this.priority, super.key});

  final LeadPriority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, color, stars) = switch (priority) {
      LeadPriority.low => (l10n.priorityLow, AppColors.textSecondary, 0),
      LeadPriority.normal => (l10n.priorityNormal, AppColors.primary, 1),
      LeadPriority.high => (l10n.priorityHigh, AppColors.warning, 2),
      LeadPriority.veryHigh =>
        (l10n.priorityVeryHigh, AppColors.danger, 3),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < stars ? Icons.star : Icons.star_outline,
              size: 14,
              color: color,
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
