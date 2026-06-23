import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/lead_chatter_controller.dart';

class ChatterComposeSheet extends ConsumerStatefulWidget {
  const ChatterComposeSheet({
    required this.leadId,
    required this.asLogNote,
    this.onPosted,
    super.key,
  });

  final int leadId;
  final bool asLogNote;
  final VoidCallback? onPosted;

  static Future<void> show(
    BuildContext context, {
    required int leadId,
    required bool asLogNote,
    VoidCallback? onPosted,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ChatterComposeSheet(
          leadId: leadId,
          asLogNote: asLogNote,
          onPosted: onPosted,
        ),
      );

  @override
  ConsumerState<ChatterComposeSheet> createState() =>
      _ChatterComposeSheetState();
}

class _ChatterComposeSheetState extends ConsumerState<ChatterComposeSheet> {
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);
    try {
      final notifier =
          ref.read(leadChatterControllerProvider(widget.leadId).notifier);
      final ok = widget.asLogNote
          ? await notifier.postLogNote(text)
          : await notifier.postDiscussion(text);
      if (ok && mounted) {
        widget.onPosted?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.asLogNote ? l10n.logNote : l10n.sendMessage;
    final hint =
        widget.asLogNote ? l10n.logNoteHint : l10n.sendMessageHint;
    final actionLabel =
        widget.asLogNote ? l10n.addLogNote : l10n.sendMessage;

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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              enabled: !_posting,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            PrimaryButton(
              label: actionLabel,
              isLoading: _posting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
