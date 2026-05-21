import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/mobile_ui/mobile_ui_list_display.dart';
import '../../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../domain/lead.dart';
import 'lead_stage_badge.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    required this.lead,
    super.key,
    this.values,
    this.listLayout,
    this.onTap,
  });

  final Lead lead;
  final Map<String, dynamic>? values;
  final MobileUiLayoutSchema? listLayout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final record = values ?? <String, dynamic>{};
    final useLayout = listLayout != null && listLayout!.isConfigured;

    final title = useLayout
        ? MobileUiListDisplay.primaryTitle(listLayout!, record)
        : (lead.title?.isNotEmpty == true ? lead.title! : lead.customerName);

    final subtitle = useLayout
        ? MobileUiListDisplay.subtitle(listLayout!, record)
        : null;

    final lines = useLayout
        ? MobileUiListDisplay.lines(listLayout!, record)
        : _legacyLines(lead);

    final stageColor = LeadStageBadge.colorFor(lead.stage);
    final stageLabel = LeadStageBadge.labelFor(lead.stage);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      stageLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: stageColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSizes.xs),
                _InfoRow(icon: lines[i].icon, text: lines[i].text),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<({IconData icon, String text})> _legacyLines(Lead lead) => [
        (icon: Icons.phone_outlined, text: lead.phone),
        (icon: Icons.person_outline, text: lead.salesperson),
        (icon: Icons.calendar_today_outlined, text: lead.createdAt.toString()),
      ];
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
