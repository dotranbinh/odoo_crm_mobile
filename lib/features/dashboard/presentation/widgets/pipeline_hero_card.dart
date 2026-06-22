import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_data.dart';

class PipelineHeroCard extends StatelessWidget {
  const PipelineHeroCard({required this.data, super.key});

  final DashboardData data;

  static const _barNew = AppColors.primaryLight;
  static const _barQualified = Color(0xFFEF9F27);
  static const _barWon = Color(0xFF1D9E75);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = data.pipelineLeadCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.borderWidth,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pipelineValue,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.currency(data.pipelineValue),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _CompositionBar(
            total: total,
            newCount: data.newCount,
            qualifiedCount: data.qualifiedCount,
            wonCount: data.wonCount,
          ),
          const SizedBox(height: AppSizes.sm),
          _Legend(
            items: [
              _LegendItem(color: _barNew, label: l10n.newLeads, count: data.newCount),
              _LegendItem(
                color: _barQualified,
                label: l10n.qualified,
                count: data.qualifiedCount,
              ),
              _LegendItem(color: _barWon, label: l10n.won, count: data.wonCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  const _CompositionBar({
    required this.total,
    required this.newCount,
    required this.qualifiedCount,
    required this.wonCount,
  });

  final int total;
  final int newCount;
  final int qualifiedCount;
  final int wonCount;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: SizedBox(
        height: 6,
        child: Row(
          children: [
            _segment(newCount, PipelineHeroCard._barNew),
            _segment(qualifiedCount, PipelineHeroCard._barQualified),
            _segment(wonCount, PipelineHeroCard._barWon),
          ],
        ),
      ),
    );
  }

  Widget _segment(int count, Color color) {
    if (count <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: count,
      child: ColoredBox(color: color),
    );
  }
}

class _LegendItem {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.md,
      runSpacing: AppSizes.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.label} ${item.count}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
