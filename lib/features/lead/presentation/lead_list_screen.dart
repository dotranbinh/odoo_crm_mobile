import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/lead_list_controller.dart';
import '../domain/lead.dart';
import 'widgets/lead_card.dart';
import 'widgets/lead_status_tabs.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(leadListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(leadListControllerProvider);

    final tabLabels = <LeadStage?, String>{
      null: l10n.all,
      LeadStage.newLead: l10n.newLeads,
      LeadStage.qualified: l10n.qualified,
      LeadStage.proposition: l10n.proposition,
      LeadStage.won: l10n.won,
      LeadStage.lost: l10n.lost,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
                AppSizes.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          state.recordType == LeadType.lead
                              ? l10n.leads
                              : l10n.opportunities,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          '${state.items.length}${state.hasMore ? '+' : ''}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.view_kanban_outlined),
                    tooltip: l10n.pipeline,
                    onPressed: () => context.push(AppRoutes.leadPipeline),
                  ),
                  PopupMenuButton<LeadSortOption>(
                    icon: const Icon(Icons.sort),
                    tooltip: l10n.sortBy,
                    onSelected: ref
                        .read(leadListControllerProvider.notifier)
                        .setSort,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: LeadSortOption.createDateDesc,
                        child: Text(l10n.sortNewest),
                      ),
                      PopupMenuItem(
                        value: LeadSortOption.createDateAsc,
                        child: Text(l10n.sortOldest),
                      ),
                      PopupMenuItem(
                        value: LeadSortOption.nameAsc,
                        child: Text(l10n.sortName),
                      ),
                      PopupMenuItem(
                        value: LeadSortOption.revenueDesc,
                        child: Text(l10n.sortRevenue),
                      ),
                      PopupMenuItem(
                        value: LeadSortOption.priorityDesc,
                        child: Text(l10n.sortPriority),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: _RecordTypeToggle(
                selected: state.recordType,
                onChanged: ref
                    .read(leadListControllerProvider.notifier)
                    .setRecordType,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SearchField(
                hint: l10n.searchLeads,
                onChanged: (q) =>
                    ref.read(leadListControllerProvider.notifier).setQuery(q),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: LeadStatusTabs(
                selected: state.selectedStage,
                labels: tabLabels,
                onSelected: (stage) => ref
                    .read(leadListControllerProvider.notifier)
                    .setStage(stage),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Expanded(child: _buildBody(context, ref, state, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    LeadListState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return LoadingView(message: l10n.loading);
    }

    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(leadListControllerProvider.notifier).refresh(),
      );
    }

    if (state.items.isEmpty) {
      return EmptyState(
        title: l10n.noLeads,
        message: l10n.noLeadsMessage,
        icon: Icons.people_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(leadListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          0,
          AppSizes.md,
          AppSizes.xxl,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[index];
          return LeadCard(
            lead: item.lead,
            values: item.values,
            listLayout: state.listLayout,
            onTap: () => context.push(AppRoutes.leadDetailFor(item.lead.id)),
          );
        },
      ),
    );
  }
}

class _RecordTypeToggle extends StatelessWidget {
  const _RecordTypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final LeadType selected;
  final ValueChanged<LeadType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: l10n.leads,
            selected: selected == LeadType.lead,
            onTap: () => onChanged(LeadType.lead),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _Chip(
            label: l10n.opportunities,
            selected: selected == LeadType.opportunity,
            onTap: () => onChanged(LeadType.opportunity),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
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
