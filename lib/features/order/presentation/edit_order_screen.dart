import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/edit_order_controller.dart';
import '../data/order_repository.dart';
import 'widgets/order_lines_editor.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  const EditOrderScreen({required this.orderId, super.key});

  final int orderId;

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  final _clientRefController = TextEditingController();
  final _noteController = TextEditingController();
  bool _controllersSynced = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(editOrderControllerProvider.notifier)
          .load(widget.orderId),
    );
  }

  @override
  void dispose() {
    _clientRefController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncControllers(EditOrderState state) {
    if (_controllersSynced) return;
    _clientRefController.text = state.clientOrderRef;
    _noteController.text = state.note;
    _controllersSynced = true;
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final order = await ref.read(editOrderControllerProvider.notifier).submit();
    if (!mounted) return;

    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderUpdated(order.number))),
      );
      context.pop(true);
    }
  }

  Future<void> _searchPartner() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final repo = ref.read(orderRepositoryProvider);

    final partner = await showModalBottomSheet<({int id, String name})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        var results = <({int id, String name})>[];
        var loading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> search(String q) async {
              setModalState(() => loading = true);
              final rows = await repo.searchPartners(q);
              setModalState(() {
                results = rows;
                loading = false;
              });
            }

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
                  children: [
                    Text(
                      l10n.customer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: l10n.searchCustomers,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: search,
                      autofocus: true,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    if (loading)
                      const CircularProgressIndicator()
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final row = results[index];
                            return ListTile(
                              title: Text(row.name),
                              onTap: () => Navigator.pop(ctx, row),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
    if (partner != null) {
      ref
          .read(editOrderControllerProvider.notifier)
          .setPartner(partner.id, partner.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(editOrderControllerProvider);
    final ctrl = ref.read(editOrderControllerProvider.notifier);
    final orderRepo = ref.read(orderRepositoryProvider);

    ref.listen(editOrderControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editOrder)),
        body: LoadingView(message: l10n.loading),
      );
    }

    if (state.error != null && state.order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editOrder)),
        body: ErrorView(
          message: state.error!,
          onRetry: () => ctrl.load(widget.orderId),
        ),
      );
    }

    _syncControllers(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editOrder),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: state.isSaving ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          AppSizes.md,
          AppSizes.screenPaddingH,
          AppSizes.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLabel(l10n.customer),
            const SizedBox(height: AppSizes.sm),
            _CustomerCard(
              partnerName: state.partnerName,
              isSaving: state.isSaving,
              onSearchPartner: _searchPartner,
            ),
            const SizedBox(height: AppSizes.lg),
            _SectionLabel(l10n.quotationInfo),
            const SizedBox(height: AppSizes.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(l10n.date),
                    subtitle: Text(
                      AppFormatters.date(state.dateOrder ?? DateTime.now()),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: AppSizes.borderWidth,
                    color: AppColors.border,
                  ),
                  ListTile(
                    title: Text(l10n.validityDate),
                    subtitle: Text(
                      state.validityDate != null
                          ? AppFormatters.date(state.validityDate!)
                          : l10n.selectDate,
                    ),
                    trailing: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onTap: state.isSaving
                        ? null
                        : () => _pickDate(
                              initial: state.validityDate,
                              onPicked: ctrl.setValidityDate,
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _clientRefController,
              decoration: InputDecoration(labelText: l10n.clientOrderRef),
              onChanged: ctrl.setClientOrderRef,
              readOnly: state.isSaving,
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: l10n.note),
              maxLines: 3,
              onChanged: ctrl.setNote,
              readOnly: state.isSaving,
            ),
            const SizedBox(height: AppSizes.lg),
            _SectionLabel(l10n.salesInfo),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<int?>(
              initialValue: state.userId,
              decoration: InputDecoration(labelText: l10n.salesperson),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.selectOption),
                ),
                for (final u in state.salespersons)
                  DropdownMenuItem(value: u.id, child: Text(u.name)),
              ],
              onChanged: state.isSaving ? null : ctrl.setUserId,
            ),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<int?>(
              initialValue: state.teamId,
              decoration: InputDecoration(labelText: l10n.salesTeam),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.selectOption),
                ),
                for (final t in state.teams)
                  DropdownMenuItem(value: t.id, child: Text(t.name)),
              ],
              onChanged: state.isSaving ? null : ctrl.setTeamId,
            ),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<int?>(
              initialValue: state.pricelistId,
              decoration: InputDecoration(labelText: l10n.pricelist),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.selectOption),
                ),
                for (final p in state.pricelists)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: state.isSaving ? null : ctrl.setPricelistId,
            ),
            const SizedBox(height: AppSizes.sm),
            DropdownButtonFormField<int?>(
              initialValue: state.paymentTermId,
              decoration: InputDecoration(labelText: l10n.paymentTerm),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.selectOption),
                ),
                for (final p in state.paymentTerms)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: state.isSaving ? null : ctrl.setPaymentTermId,
            ),
            const SizedBox(height: AppSizes.lg),
            OrderLinesEditor(
              lines: state.lines,
              onChanged: ctrl.setLines,
              onSearchProducts: orderRepo.searchProducts,
              onFetchPrice: orderRepo.fetchProductListPrice,
            ),
            const SizedBox(height: AppSizes.md),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${l10n.total}: ${AppFormatters.currency(state.linesTotal, symbol: '\$')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            PrimaryButton(
              label: l10n.save,
              isLoading: state.isSaving,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.partnerName,
    required this.isSaving,
    required this.onSearchPartner,
  });

  final String? partnerName;
  final bool isSaving;
  final VoidCallback onSearchPartner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPartner = partnerName?.isNotEmpty == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasPartner ? partnerName! : l10n.customerRequired,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: hasPartner
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            TextButton.icon(
              onPressed: isSaving ? null : onSearchPartner,
              icon: const Icon(Icons.search, size: 18),
              label: Text(l10n.selectCustomer),
            ),
          ],
        ),
      ),
    );
  }
}
