import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/lead.dart';

class LeadStageBadge extends StatelessWidget {
  const LeadStageBadge({
    required this.stage,
    super.key,
    this.compact = false,
  });

  final LeadStage stage;
  final bool compact;

  static Color colorFor(LeadStage stage) => switch (stage) {
        LeadStage.newLead => AppColors.primary,
        LeadStage.qualified => AppColors.warning,
        LeadStage.proposition => const Color(0xFF17A2B8),
        LeadStage.won => AppColors.success,
        LeadStage.lost => AppColors.danger,
      };

  static String labelFor(LeadStage stage) => switch (stage) {
        LeadStage.newLead => 'New',
        LeadStage.qualified => 'Qualified',
        LeadStage.proposition => 'Proposition',
        LeadStage.won => 'Won',
        LeadStage.lost => 'Lost',
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(stage);
    final label = labelFor(stage);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: (compact
                ? Theme.of(context).textTheme.labelSmall
                : Theme.of(context).textTheme.labelMedium)
            ?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
