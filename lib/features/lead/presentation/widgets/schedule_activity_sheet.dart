import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/lead_scheduled_activities_controller.dart';
import '../../data/lead_activity_repository.dart';
import '../../domain/scheduled_activity.dart';

class ScheduleActivitySheet extends ConsumerStatefulWidget {
  const ScheduleActivitySheet({
    required this.leadId,
    required this.onScheduled,
    super.key,
  });

  final int leadId;
  final VoidCallback onScheduled;

  static Future<void> show(
    BuildContext context, {
    required int leadId,
    required VoidCallback onScheduled,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ScheduleActivitySheet(
          leadId: leadId,
          onScheduled: onScheduled,
        ),
      );

  @override
  ConsumerState<ScheduleActivitySheet> createState() =>
      _ScheduleActivitySheetState();
}

class _ScheduleActivitySheetState extends ConsumerState<ScheduleActivitySheet> {
  final _summaryController = TextEditingController();
  List<({int id, String name})> _types = [];
  int? _typeId;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final types =
        await ref.read(leadActivityRepositoryProvider).fetchActivityTypes();
    if (mounted) {
      setState(() {
        _types = types;
        _typeId = types.isNotEmpty ? types.first.id : null;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (_typeId == null || _summaryController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final ok = await ref
        .read(leadScheduledActivitiesControllerProvider(widget.leadId).notifier)
        .schedule(
          activityTypeId: _typeId!,
          summary: _summaryController.text.trim(),
          dateDeadline: _deadline,
        );
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        widget.onScheduled();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          AppSizes.md,
          AppSizes.screenPaddingH,
          MediaQuery.viewInsetsOf(context).bottom + AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.scheduleActivity,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<int>(
                initialValue: _typeId,
                decoration: InputDecoration(labelText: l10n.activityType),
                items: [
                  for (final t in _types)
                    DropdownMenuItem(value: t.id, child: Text(t.name)),
                ],
                onChanged: (v) => setState(() => _typeId = v),
              ),
              const SizedBox(height: AppSizes.sm),
              TextField(
                controller: _summaryController,
                decoration: InputDecoration(labelText: l10n.summary),
              ),
              const SizedBox(height: AppSizes.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.deadline),
                subtitle: Text(AppFormatters.date(_deadline)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.scheduleActivity),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LeadScheduledActivitiesList extends ConsumerWidget {
  const LeadScheduledActivitiesList({
    required this.leadId,
    super.key,
  });

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(leadScheduledActivitiesControllerProvider(leadId));

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Text(
          l10n.noScheduledActivities,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final activity in state.activities)
          _ActivityCard(leadId: leadId, activity: activity),
      ],
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard({required this.leadId, required this.activity});

  final int leadId;
  final ScheduledActivity activity;

  Color get _accent => switch (activity.state) {
        ScheduledActivityState.overdue => AppColors.statusLostText,
        ScheduledActivityState.today => AppColors.statusQualifiedText,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.sm,
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.summary.isNotEmpty
                      ? activity.summary
                      : activity.activityTypeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.activityTypeName} · ${activity.assigneeName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.date(activity.dateDeadline),
                  style: TextStyle(fontSize: 12, color: _accent),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(
                    leadScheduledActivitiesControllerProvider(leadId).notifier,
                  )
                  .markDone(activity.id);
            },
            child: Text(l10n.markDone),
          ),
        ],
      ),
    );
  }
}
