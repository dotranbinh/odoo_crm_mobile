import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/lead_pipeline_controller.dart';
import '../domain/lead.dart';
import '../domain/lead_list_item.dart';

class LeadPipelineScreen extends ConsumerWidget {
  const LeadPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(leadPipelineControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pipeline),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list_outlined),
            tooltip: l10n.listView,
            onPressed: () => context.go(AppRoutes.leads),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.sm,
            ),
            child: _TypeToggle(
              selected: state.recordType,
              onChanged: ref
                  .read(leadPipelineControllerProvider.notifier)
                  .setRecordType,
            ),
          ),
          Expanded(
            child: state.isLoading
                ? LoadingView(message: l10n.loading)
                : state.error != null
                    ? ErrorView(
                        message: state.error!,
                        onRetry: () => ref
                            .read(leadPipelineControllerProvider.notifier)
                            .refresh(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(leadPipelineControllerProvider.notifier)
                            .refresh(),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.md,
                            0,
                            AppSizes.md,
                            AppSizes.xxl,
                          ),
                          children: [
                            for (final column in state.columns)
                              _PipelineColumnWidget(column: column),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selected, required this.onChanged});

  final LeadType selected;
  final ValueChanged<LeadType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _ToggleChip(
            label: l10n.leads,
            selected: selected == LeadType.lead,
            onTap: () => onChanged(LeadType.lead),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _ToggleChip(
            label: l10n.opportunities,
            selected: selected == LeadType.opportunity,
            onTap: () => onChanged(LeadType.opportunity),
          ),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryTintLight : AppColors.surfaceTint,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected
                  ? AppColors.primaryTintText
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelineColumnWidget extends ConsumerWidget {
  const _PipelineColumnWidget({required this.column});

  final PipelineColumn column;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        ref
            .read(leadPipelineControllerProvider.notifier)
            .moveLeadToStage(details.data, column.stageId);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: AppSizes.md),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primaryTintLight
                : AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : AppColors.border,
              width: AppSizes.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      column.stageName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${column.items.length} · ${AppFormatters.currency(column.totalRevenue)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.sm,
                    0,
                    AppSizes.sm,
                    AppSizes.sm,
                  ),
                  children: [
                    for (final item in column.items)
                      _KanbanCard(item: item),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.item});

  final LeadListItem item;

  @override
  Widget build(BuildContext context) {
    final lead = item.lead;
    final name = lead.title?.isNotEmpty == true
        ? lead.title!
        : lead.customerName;

    return LongPressDraggable<int>(
      data: lead.id,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: SizedBox(
          width: 240,
          child: _CardBody(name: name, revenue: lead.expectedRevenue),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _CardBody(name: name, revenue: lead.expectedRevenue),
      ),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.leadDetailFor(lead.id)),
        child: _CardBody(name: name, revenue: lead.expectedRevenue),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.name, this.revenue});

  final String name;
  final double? revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (revenue != null && revenue! > 0) ...[
            const SizedBox(height: 4),
            Text(
              AppFormatters.currency(revenue!),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
