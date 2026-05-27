import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/odoo_detail_section.dart';
import '../../../l10n/app_localizations.dart';
import '../application/lead_chatter_controller.dart';
import '../application/lead_detail_controller.dart';
import '../domain/lead.dart';
import '../domain/lead_detail_view_data.dart';
import 'widgets/lead_chatter_card.dart';
import 'widgets/lead_priority_chip.dart';
import 'widgets/lead_stage_badge.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({required this.leadId, super.key});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(leadDetailControllerProvider(leadId));

    return Scaffold(
      body: async.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.leadDetailTitle)),
          body: LoadingView(message: l10n.loading),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: Text(l10n.leadDetailTitle)),
          body: ErrorView(
            message: e.toString(),
            onRetry: () => ref
                .read(leadDetailControllerProvider(leadId).notifier)
                .refresh(),
          ),
        ),
        data: (view) => _LeadDetailBody(view: view),
      ),
    );
  }
}

class _LeadDetailBody extends ConsumerWidget {
  const _LeadDetailBody({required this.view});

  final LeadDetailViewData view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lead = view.summary;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(leadDetailControllerProvider(lead.id).notifier).refresh();
        await ref.read(leadChatterControllerProvider(lead.id).notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: LeadStageBadge.colorFor(lead.stage),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editLead,
                onPressed: () async {
                  final updated = await context.push<bool>(
                    AppRoutes.leadEditFor(lead.id),
                  );
                  if (updated == true) {
                    await ref
                        .read(leadDetailControllerProvider(lead.id).notifier)
                        .refresh();
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.md,
              ),
              title: Text(
                lead.title?.isNotEmpty == true
                    ? lead.title!
                    : lead.customerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _LeadHeaderBackground(lead: lead),
            ),
          ),
          SliverList.list(
            children: [
              const SizedBox(height: AppSizes.md),
              _QuickActionsRow(lead: lead, values: view.values),
              const SizedBox(height: AppSizes.md),
              for (final group in view.schema.displayGroups)
                OdooDetailSection(
                  group: group,
                  fieldDefinitions: view.schema.fields,
                  values: view.values,
                ),
              LeadChatterCard(leadId: lead.id),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadHeaderBackground extends StatelessWidget {
  const _LeadHeaderBackground({required this.lead});

  final Lead lead;

  static const _minHeightForDetails = 120.0;

  @override
  Widget build(BuildContext context) {
    final stageColor = LeadStageBadge.colorFor(lead.stage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showDetails = constraints.maxHeight >= _minHeightForDetails;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                stageColor,
                Color.alphaBlend(
                  Colors.black.withValues(alpha: 0.2),
                  stageColor,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: showDetails
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      52,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSizes.sm,
                          runSpacing: AppSizes.xs,
                          children: [
                            LeadStageBadge(stage: lead.stage),
                            LeadPriorityChip(priority: lead.priority),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          lead.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lead.companyName?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            lead.companyName!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.lead, required this.values});

  final Lead lead;
  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = lead.phone;
    final email = lead.email;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.call,
              label: l10n.callAction,
              color: AppColors.success,
              enabled: phone.isNotEmpty,
              onTap: () => _copy(context, phone, '${l10n.phone} copied'),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: _ActionTile(
              icon: Icons.email_outlined,
              label: l10n.emailAction,
              color: AppColors.primary,
              enabled: email.isNotEmpty,
              onTap: () => _copy(context, email, '${l10n.email} copied'),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: _ActionTile(
              icon: Icons.event_note_outlined,
              label: l10n.deadline,
              color: AppColors.warning,
              enabled: lead.dateDeadline != null,
              onTap: () {
                if (lead.dateDeadline == null) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppFormatters.date(lead.dateDeadline!)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value, String snack) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snack), duration: const Duration(seconds: 2)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.textSecondary;
    return Material(
      color: effectiveColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: Column(
            children: [
              Icon(icon, color: effectiveColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
