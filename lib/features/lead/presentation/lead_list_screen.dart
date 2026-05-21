import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/lead_list_controller.dart';
import '../domain/lead.dart';
import 'widgets/lead_card.dart';
import 'widgets/lead_filter_sheet.dart';
import 'widgets/lead_status_tabs.dart';

class LeadListScreen extends ConsumerWidget {
  const LeadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(leadListControllerProvider);

    final tabLabels = <LeadStage?, String>{
      null: l10n.all,
      LeadStage.newLead: l10n.newLeads,
      LeadStage.qualified: l10n.qualified,
      LeadStage.won: l10n.won,
      LeadStage.lost: l10n.lost,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leads)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: l10n.searchLeads,
                    onChanged: (q) => ref
                        .read(leadListControllerProvider.notifier)
                        .setQuery(q),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                IconButton.filledTonal(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const LeadFilterSheet(),
                  ),
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
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
          const SizedBox(height: AppSizes.md),
          Expanded(child: _buildBody(context, ref, state, l10n)),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
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
