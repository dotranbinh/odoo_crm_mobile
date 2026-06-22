import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/lead_chatter_controller.dart';
import '../../domain/mail_message.dart';

/// Read-only activity timeline (dot + connecting line) following the dashboard
/// timeline pattern. Renders tracking-type chatter entries chronologically.
class LeadActivityTimeline extends ConsumerWidget {
  const LeadActivityTimeline({required this.leadId, super.key});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(leadChatterControllerProvider(leadId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.xl),
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
        final items = messages
            .where((m) => m.kind == MailMessageKind.tracking)
            .toList();

        if (items.isEmpty) {
          return const _EmptyActivity();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            AppSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                _TimelineRow(
                  message: items[i],
                  isFirst: i == 0,
                  isLast: i == items.length - 1,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.message,
    required this.isFirst,
    required this.isLast,
  });

  final MailMessage message;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final title = message.displayText.isNotEmpty
        ? message.displayText
        : (message.subtypeName ?? '');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.dateTime(message.date),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Column(
        children: [
          const Icon(Icons.history, size: 28, color: AppColors.textSecondary),
          const SizedBox(height: AppSizes.sm),
          Text(
            'No activity yet',
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
