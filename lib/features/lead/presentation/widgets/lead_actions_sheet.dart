import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/lead_repository.dart';
import '../../domain/lead.dart';

typedef LeadActionCallback = Future<void> Function();

class LeadActionsSheet extends ConsumerStatefulWidget {
  const LeadActionsSheet({
    required this.lead,
    required this.onActionComplete,
    super.key,
  });

  final Lead lead;
  final VoidCallback onActionComplete;

  static Future<void> show(
    BuildContext context, {
    required Lead lead,
    required VoidCallback onActionComplete,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => LeadActionsSheet(
          lead: lead,
          onActionComplete: onActionComplete,
        ),
      );

  @override
  ConsumerState<LeadActionsSheet> createState() => _LeadActionsSheetState();
}

class _LeadActionsSheetState extends ConsumerState<LeadActionsSheet> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        widget.onActionComplete();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lead = widget.lead;
    final repo = ref.read(leadRepositoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          AppSizes.md,
          AppSizes.screenPaddingH,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.leadActions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            if (lead.stage != LeadStage.won && lead.stage != LeadStage.lost)
              _ActionTile(
                icon: Icons.emoji_events_outlined,
                label: l10n.markWon,
                color: AppColors.statusWonText,
                enabled: !_busy,
                onTap: () => _run(() => repo.markWon(lead.id)),
              ),
            if (lead.stage != LeadStage.lost)
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: l10n.markLost,
                color: AppColors.statusLostText,
                enabled: !_busy,
                onTap: () async {
                  Navigator.pop(context);
                  await _MarkLostSheet.show(
                    context,
                    leadId: lead.id,
                    onComplete: widget.onActionComplete,
                  );
                },
              ),
            _ActionTile(
              icon: Icons.swap_horiz,
              label: l10n.changeStage,
              enabled: !_busy,
              onTap: () async {
                Navigator.pop(context);
                await _StagePickerSheet.show(
                  context,
                  leadId: lead.id,
                  onComplete: widget.onActionComplete,
                );
              },
            ),
            _ActionTile(
              icon: Icons.person_outline,
              label: l10n.assignSalesperson,
              enabled: !_busy,
              onTap: () async {
                Navigator.pop(context);
                await _AssignSheet.show(
                  context,
                  leadId: lead.id,
                  onComplete: widget.onActionComplete,
                );
              },
            ),
            if (lead.recordType == LeadType.lead)
              _ActionTile(
                icon: Icons.transform,
                label: l10n.convertToOpportunity,
                enabled: !_busy,
                onTap: () => _run(() => repo.convertToOpportunity(lead.id)),
              ),
            if (lead.stage != LeadStage.lost)
              _ActionTile(
                icon: Icons.request_quote_outlined,
                label: l10n.newQuotation,
                enabled: !_busy,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.createOrderForLead(lead.id));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: enabled ? color : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _MarkLostSheet extends ConsumerStatefulWidget {
  const _MarkLostSheet({
    required this.leadId,
    required this.onComplete,
  });

  final int leadId;
  final VoidCallback onComplete;

  static Future<void> show(
    BuildContext context, {
    required int leadId,
    required VoidCallback onComplete,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _MarkLostSheet(leadId: leadId, onComplete: onComplete),
      );

  @override
  ConsumerState<_MarkLostSheet> createState() => _MarkLostSheetState();
}

class _MarkLostSheetState extends ConsumerState<_MarkLostSheet> {
  int? _reasonId;
  final _noteController = TextEditingController();
  List<({int id, String name})> _reasons = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    final reasons = await ref.read(leadRepositoryProvider).fetchLostReasons();
    if (mounted) {
      setState(() {
        _reasons = reasons;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(leadRepositoryProvider).markLost(
            id: widget.leadId,
            lostReasonId: _reasonId,
            closingNote: _noteController.text.trim(),
          );
      if (mounted) {
        widget.onComplete();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
              l10n.markLost,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<int?>(
                initialValue: _reasonId,
                decoration: InputDecoration(labelText: l10n.lostReason),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.selectOption),
                  ),
                  for (final r in _reasons)
                    DropdownMenuItem(value: r.id, child: Text(r.name)),
                ],
                onChanged: (v) => setState(() => _reasonId = v),
              ),
              const SizedBox(height: AppSizes.sm),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.note),
                maxLines: 3,
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
                    : Text(l10n.markLost),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StagePickerSheet extends ConsumerStatefulWidget {
  const _StagePickerSheet({
    required this.leadId,
    required this.onComplete,
  });

  final int leadId;
  final VoidCallback onComplete;

  static Future<void> show(
    BuildContext context, {
    required int leadId,
    required VoidCallback onComplete,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (_) =>
            _StagePickerSheet(leadId: leadId, onComplete: onComplete),
      );

  @override
  ConsumerState<_StagePickerSheet> createState() => _StagePickerSheetState();
}

class _StagePickerSheetState extends ConsumerState<_StagePickerSheet> {
  List<({int id, String name})> _stages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stages = await ref.read(leadRepositoryProvider).fetchLeadStages();
    if (mounted) {
      setState(() {
        _stages = stages;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.changeStage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              for (final stage in _stages)
                ListTile(
                  title: Text(stage.name),
                  onTap: () async {
                    try {
                      await ref
                          .read(leadRepositoryProvider)
                          .changeStage(widget.leadId, stage.id);
                      if (context.mounted) {
                        widget.onComplete();
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _AssignSheet extends ConsumerStatefulWidget {
  const _AssignSheet({
    required this.leadId,
    required this.onComplete,
  });

  final int leadId;
  final VoidCallback onComplete;

  static Future<void> show(
    BuildContext context, {
    required int leadId,
    required VoidCallback onComplete,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => _AssignSheet(leadId: leadId, onComplete: onComplete),
      );

  @override
  ConsumerState<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends ConsumerState<_AssignSheet> {
  List<({int id, String name})> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await ref.read(leadRepositoryProvider).fetchSalespersons();
    if (mounted) {
      setState(() {
        _users = users;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.assignSalesperson,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              for (final user in _users)
                ListTile(
                  title: Text(user.name),
                  onTap: () async {
                    try {
                      await ref
                          .read(leadRepositoryProvider)
                          .assignSalesperson(widget.leadId, user.id);
                      if (context.mounted) {
                        widget.onComplete();
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}
