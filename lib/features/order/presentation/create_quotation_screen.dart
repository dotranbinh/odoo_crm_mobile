import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/create_quotation_controller.dart';
import '../data/order_repository.dart';
import 'widgets/order_lines_editor.dart';

class CreateQuotationScreen extends ConsumerStatefulWidget {
  const CreateQuotationScreen({this.leadId, super.key});

  final int? leadId;

  @override
  ConsumerState<CreateQuotationScreen> createState() =>
      _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends ConsumerState<CreateQuotationScreen> {
  final _clientRefController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(createQuotationControllerProvider.notifier)
          .load(leadId: widget.leadId),
    );
  }

  @override
  void dispose() {
    _clientRefController.dispose();
    _noteController.dispose();
    super.dispose();
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
    final order =
        await ref.read(createQuotationControllerProvider.notifier).submit();
    if (!mounted) return;

    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quotationCreated(order.number))),
      );
      context.pop(order.id);
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
          .read(createQuotationControllerProvider.notifier)
          .setPartner(partner.id, partner.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(createQuotationControllerProvider);
    final ctrl = ref.read(createQuotationControllerProvider.notifier);
    final orderRepo = ref.read(orderRepositoryProvider);

    ref.listen(createQuotationControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createQuotation),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: state.isSaving ? null : () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? LoadingView(message: l10n.loading)
          : SingleChildScrollView(
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
                  _CustomerSection(
                    partnerName: state.partnerName,
                    needsPartner: state.needsPartner,
                    fromLead: widget.leadId != null,
                    isSaving: state.isSaving,
                    onCreatePartner: ctrl.createPartnerFromLead,
                    onSearchPartner:
                        widget.leadId == null ? _searchPartner : null,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _SectionLabel(l10n.quotationInfo),
                  const SizedBox(height: AppSizes.sm),
                  Card(
                    child: Column(
                      children: [
                        if (state.origin != null &&
                            state.origin!.isNotEmpty) ...[
                          ListTile(
                            title: Text(l10n.origin),
                            subtitle: Text(state.origin!),
                          ),
                          const Divider(
                            height: 1,
                            thickness: AppSizes.borderWidth,
                            color: AppColors.border,
                          ),
                        ],
                        ListTile(
                          title: Text(l10n.date),
                          subtitle: Text(
                            AppFormatters.date(
                              state.dateOrder ?? DateTime.now(),
                            ),
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
                    decoration: InputDecoration(
                      labelText: l10n.clientOrderRef,
                    ),
                    onChanged: ctrl.setClientOrderRef,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(labelText: l10n.note),
                    maxLines: 3,
                    onChanged: ctrl.setNote,
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
                    label: l10n.createQuotation,
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

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({
    required this.partnerName,
    required this.needsPartner,
    required this.fromLead,
    required this.isSaving,
    required this.onCreatePartner,
    this.onSearchPartner,
  });

  final String? partnerName;
  final bool needsPartner;
  final bool fromLead;
  final bool isSaving;
  final VoidCallback onCreatePartner;
  final VoidCallback? onSearchPartner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPartner = partnerName != null && partnerName!.isNotEmpty;

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
                          : (needsPartner
                              ? AppColors.warning
                              : AppColors.textSecondary),
                    ),
              ),
            ),
            if (needsPartner) ...[
              const SizedBox(width: AppSizes.sm),
              TextButton.icon(
                onPressed: isSaving ? null : onCreatePartner,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(l10n.createCustomer),
              ),
            ] else if (!fromLead && onSearchPartner != null) ...[
              const SizedBox(width: AppSizes.sm),
              TextButton.icon(
                onPressed: isSaving ? null : onSearchPartner,
                icon: const Icon(Icons.search, size: 18),
                label: Text(l10n.selectCustomer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
