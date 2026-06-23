import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/lead_chatter_controller.dart';
import '../../domain/mail_message.dart';
import 'chatter_compose_sheet.dart';
import 'lead_detail_action_button.dart';

class LeadChatterCard extends ConsumerWidget {
  const LeadChatterCard({
    required this.leadId,
    super.key,
    this.showHeader = true,
    this.padded = true,
    this.showComposer = true,
    this.kinds,
    this.emptyIcon = Icons.forum_outlined,
    this.emptyText,
  });

  final int leadId;
  final bool showHeader;
  final bool padded;
  final bool showComposer;
  final Set<MailMessageKind>? kinds;
  final IconData emptyIcon;
  final String? emptyText;

  void _openComposer(BuildContext context, WidgetRef ref, {required bool asLogNote}) {
    ChatterComposeSheet.show(
      context,
      leadId: leadId,
      asLogNote: asLogNote,
      onPosted: () => ref
          .read(leadChatterControllerProvider(leadId).notifier)
          .refresh(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncMessages = ref.watch(leadChatterControllerProvider(leadId));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.sm,
            ),
            child: SectionHeader(title: l10n.chatterAndNotes),
          ),
          const Divider(height: 1),
        ],
        if (showComposer) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.md,
              showHeader ? AppSizes.sm : 0,
              AppSizes.md,
              AppSizes.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LeadDetailActionButton(
                  label: l10n.logNote,
                  icon: Icons.sticky_note_2_outlined,
                  onPressed: () =>
                      _openComposer(context, ref, asLogNote: true),
                ),
                const SizedBox(height: AppSizes.sm),
                LeadDetailActionButton(
                  label: l10n.sendMessage,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () =>
                      _openComposer(context, ref, asLogNote: false),
                ),
              ],
            ),
          ),
        ],
        asyncMessages.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                Text(e.toString()),
                const SizedBox(height: AppSizes.sm),
                OutlinedButton(
                  onPressed: () => ref
                      .read(leadChatterControllerProvider(leadId).notifier)
                      .refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (messages) {
            final visible = kinds == null
                ? messages
                : messages.where((m) => kinds!.contains(m.kind)).toList();
            if (visible.isEmpty) {
              return _EmptyMessages(
                icon: emptyIcon,
                text: emptyText ?? l10n.noChatterMessages,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _MessageTile(message: visible[index], l10n: l10n),
            );
          },
        ),
      ],
    );

    if (!padded) return content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: content,
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.textSecondary),
          const SizedBox(height: AppSizes.sm),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.l10n});

  final MailMessage message;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final display = message.displayText;
    if (display.isEmpty) return const SizedBox.shrink();

    final kind = message.kind;
    final badge = _badgeFor(kind);
    final icon = _iconFor(kind);
    final color = _colorFor(kind);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              message.authorName,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            AppFormatters.relative(message.date),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              badge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            display,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _badgeFor(MailMessageKind kind) => switch (kind) {
        MailMessageKind.logNote => l10n.logNote,
        MailMessageKind.discussion => l10n.chatterMessage,
        MailMessageKind.email => l10n.email,
        MailMessageKind.tracking => l10n.activityLog,
      };

  IconData _iconFor(MailMessageKind kind) => switch (kind) {
        MailMessageKind.logNote => Icons.sticky_note_2_outlined,
        MailMessageKind.discussion => Icons.chat_bubble_outline,
        MailMessageKind.email => Icons.email_outlined,
        MailMessageKind.tracking => Icons.history,
      };

  Color _colorFor(MailMessageKind kind) => switch (kind) {
        MailMessageKind.logNote => AppColors.warning,
        MailMessageKind.discussion => AppColors.primary,
        MailMessageKind.email => AppColors.accent,
        MailMessageKind.tracking => AppColors.textSecondary,
      };
}
