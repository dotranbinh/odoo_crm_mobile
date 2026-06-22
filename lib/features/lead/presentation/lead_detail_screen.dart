import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/url_launcher_util.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/odoo_detail_section.dart';
import '../../../l10n/app_localizations.dart';
import '../application/lead_chatter_controller.dart';
import '../application/lead_detail_controller.dart';
import '../application/lead_scheduled_activities_controller.dart';
import '../domain/lead.dart';
import '../domain/lead_detail_view_data.dart';
import '../domain/mail_message.dart';
import 'widgets/lead_actions_sheet.dart';
import 'widgets/lead_activity_timeline.dart';
import 'widgets/lead_chatter_card.dart';
import 'widgets/lead_stage_badge.dart';
import 'widgets/schedule_activity_sheet.dart';

enum _DetailTab { info, notes, activity }

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({required this.leadId, super.key});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(leadDetailControllerProvider(leadId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.leadDetailTitle)),
        body: LoadingView(message: l10n.loading),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.leadDetailTitle)),
        body: ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(leadDetailControllerProvider(leadId).notifier).refresh(),
        ),
      ),
      data: (view) => _LeadDetailBody(view: view),
    );
  }
}

class _LeadDetailBody extends ConsumerStatefulWidget {
  const _LeadDetailBody({required this.view});

  final LeadDetailViewData view;

  @override
  ConsumerState<_LeadDetailBody> createState() => _LeadDetailBodyState();
}

class _LeadDetailBodyState extends ConsumerState<_LeadDetailBody> {
  _DetailTab _tab = _DetailTab.info;

  Lead get _lead => widget.view.summary;

  Future<void> _refreshAll() async {
    await ref.read(leadDetailControllerProvider(_lead.id).notifier).refresh();
    await ref.read(leadChatterControllerProvider(_lead.id).notifier).refresh();
    await ref
        .read(leadScheduledActivitiesControllerProvider(_lead.id).notifier)
        .refresh();
  }

  Future<void> _onEdit() async {
    final updated = await context.push<bool>(AppRoutes.leadEditFor(_lead.id));
    if (updated == true) {
      await _refreshAll();
    }
  }

  void _onActionsComplete() {
    ref.read(leadDetailControllerProvider(_lead.id).notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lead = _lead;

    return Scaffold(
      floatingActionButton: _tab == _DetailTab.activity
          ? FloatingActionButton(
              onPressed: () => ScheduleActivitySheet.show(
                context,
                leadId: lead.id,
                onScheduled: () => ref
                    .read(
                      leadScheduledActivitiesControllerProvider(lead.id)
                          .notifier,
                    )
                    .refresh(),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            children: [
              _DetailHeader(
                label: l10n.leads,
                onEdit: _onEdit,
                onActions: () => LeadActionsSheet.show(
                  context,
                  lead: lead,
                  onActionComplete: _onActionsComplete,
                ),
              ),
              _LeadHero(lead: lead),
              const SizedBox(height: AppSizes.sm),
              _ContactActions(lead: lead),
              const SizedBox(height: AppSizes.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: _DetailTabBar(
                  selected: _tab,
                  onSelected: (t) => setState(() => _tab = t),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _tabContent(lead, l10n),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabContent(Lead lead, AppLocalizations l10n) {
    switch (_tab) {
      case _DetailTab.info:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final group in widget.view.schema.displayGroups)
              OdooDetailSection(
                group: group,
                fieldDefinitions: widget.view.schema.fields,
                values: widget.view.values,
                outsideLabel: true,
              ),
          ],
        );
      case _DetailTab.notes:
        return LeadChatterCard(
          leadId: lead.id,
          showHeader: false,
          kinds: const {
            MailMessageKind.logNote,
            MailMessageKind.discussion,
            MailMessageKind.email,
          },
          emptyIcon: Icons.notes_outlined,
          emptyText: l10n.noNotesYet,
        );
      case _DetailTab.activity:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Text(
                l10n.scheduledActivities,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            LeadScheduledActivitiesList(leadId: lead.id),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Text(
                l10n.activityHistory,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            LeadActivityTimeline(leadId: lead.id),
          ],
        );
    }
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.label,
    required this.onEdit,
    required this.onActions,
  });

  final String label;
  final VoidCallback onEdit;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.sm, AppSizes.sm, AppSizes.sm, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            color: AppColors.textPrimary,
            tooltip: l10n.leadActions,
            onPressed: onActions,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.textPrimary,
            tooltip: l10n.editLead,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _LeadHero extends StatelessWidget {
  const _LeadHero({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final name = lead.title?.isNotEmpty == true ? lead.title! : lead.customerName;
    final company = lead.companyName ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LeadStageBadge.backgroundFor(lead.stage),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(name),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: LeadStageBadge.textColorFor(lead.stage),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (company.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              company,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          LeadStageBadge(
            stage: lead.stage,
            compact: true,
            labelOverride: lead.stageOdooName,
          ),
        ],
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

class _ContactActions extends StatelessWidget {
  const _ContactActions({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = lead.phone;
    final messageTarget = lead.mobile?.isNotEmpty == true ? lead.mobile! : phone;
    final email = lead.email;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CircleAction(
            icon: Icons.phone_outlined,
            label: l10n.callAction,
            background: AppColors.statusWonBg,
            foreground: AppColors.statusWonText,
            enabled: phone.isNotEmpty,
            onTap: () => _launchOrCopy(
              context,
              phone,
              () => UrlLauncherUtil.launchPhone(phone),
              '${l10n.phone} copied',
            ),
            onLongPress: () => _copy(context, phone, '${l10n.phone} copied'),
          ),
          _CircleAction(
            icon: Icons.chat_bubble_outline,
            label: l10n.messageAction,
            background: AppColors.surfaceTint,
            foreground: AppColors.textTertiary,
            enabled: messageTarget.isNotEmpty,
            onTap: () => _launchOrCopy(
              context,
              messageTarget,
              () => UrlLauncherUtil.launchSms(messageTarget),
              '${l10n.phone} copied',
            ),
            onLongPress: () =>
                _copy(context, messageTarget, '${l10n.phone} copied'),
          ),
          _CircleAction(
            icon: Icons.mail_outline,
            label: l10n.emailAction,
            background: AppColors.surfaceTint,
            foreground: AppColors.textTertiary,
            enabled: email.isNotEmpty,
            onTap: () => _launchOrCopy(
              context,
              email,
              () => UrlLauncherUtil.launchEmail(email),
              '${l10n.email} copied',
            ),
            onLongPress: () => _copy(context, email, '${l10n.email} copied'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchOrCopy(
    BuildContext context,
    String value,
    Future<bool> Function() launch,
    String copySnack,
  ) async {
    if (value.isEmpty) return;
    final launched = await launch();
    if (!launched && context.mounted) {
      _copy(context, value, copySnack);
    }
  }

  void _copy(BuildContext context, String value, String snack) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snack), duration: const Duration(seconds: 2)),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.onLongPress,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? background : AppColors.surfaceTint;
    final fg = enabled ? foreground : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            onLongPress: enabled ? onLongPress : null,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, size: 20, color: fg),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

class _DetailTabBar extends StatelessWidget {
  const _DetailTabBar({required this.selected, required this.onSelected});

  final _DetailTab selected;
  final ValueChanged<_DetailTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: l10n.infoTab,
            selected: selected == _DetailTab.info,
            onTap: () => onSelected(_DetailTab.info),
          ),
          const SizedBox(width: AppSizes.lg),
          _TabItem(
            label: l10n.notesTab,
            selected: selected == _DetailTab.notes,
            onTap: () => onSelected(_DetailTab.notes),
          ),
          const SizedBox(width: AppSizes.lg),
          _TabItem(
            label: l10n.activityTab,
            selected: selected == _DetailTab.activity,
            onTap: () => onSelected(_DetailTab.activity),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected
                      ? AppColors.primaryTintText
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
