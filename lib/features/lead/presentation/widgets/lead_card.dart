import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/mobile_ui/mobile_ui_list_display.dart';
import '../../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../../core/utils/formatters.dart';
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
        : (lead.companyName ?? '');

    final layoutLines = useLayout
        ? MobileUiListDisplay.lines(listLayout!, record)
        : const <({IconData icon, String text})>[];

    final phone = lead.phone;
    final timeLabel = AppFormatters.relative(lead.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initials: _initials(title), stage: lead.stage),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        LeadStageBadge(
                          stage: lead.stage,
                          compact: true,
                          labelOverride: lead.stageOdooName,
                        ),
                      ],
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    if (layoutLines.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      for (final line in layoutLines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(
                                line.icon,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  line.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ] else if (phone.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        timeLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.stage});

  final String initials;
  final LeadStage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LeadStageBadge.backgroundFor(stage),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: LeadStageBadge.textColorFor(stage),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
