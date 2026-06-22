import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/lead.dart';

class LeadStageBadge extends StatelessWidget {
  const LeadStageBadge({
    required this.stage,
    super.key,
    this.compact = false,
    this.labelOverride,
  });

  final LeadStage stage;
  final bool compact;
  final String? labelOverride;

  static Color colorFor(LeadStage stage) => switch (stage) {
        LeadStage.newLead => AppColors.primary,
        LeadStage.qualified => AppColors.warning,
        LeadStage.proposition => const Color(0xFF17A2B8),
        LeadStage.won => AppColors.success,
        LeadStage.lost => AppColors.danger,
      };

  static Color backgroundFor(LeadStage stage) => switch (stage) {
        LeadStage.newLead => AppColors.statusNewBg,
        LeadStage.qualified => AppColors.statusQualifiedBg,
        LeadStage.proposition => const Color(0xFFE3F1F4),
        LeadStage.won => AppColors.statusWonBg,
        LeadStage.lost => AppColors.statusLostBg,
      };

  static Color textColorFor(LeadStage stage) => switch (stage) {
        LeadStage.newLead => AppColors.statusNewText,
        LeadStage.qualified => AppColors.statusQualifiedText,
        LeadStage.proposition => const Color(0xFF0E5A6B),
        LeadStage.won => AppColors.statusWonText,
        LeadStage.lost => AppColors.statusLostText,
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
    final background = backgroundFor(stage);
    final textColor = textColorFor(stage);
    final label = labelOverride ?? labelFor(stage);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: (compact
                ? Theme.of(context).textTheme.labelSmall
                : Theme.of(context).textTheme.labelMedium)
            ?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
