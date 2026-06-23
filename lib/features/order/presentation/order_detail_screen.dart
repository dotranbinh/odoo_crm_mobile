import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/order_detail_controller.dart';
import '../domain/order.dart';
import '../domain/order_line.dart';
import 'widgets/order_status_chip.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(orderDetailControllerProvider(orderId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetailTitle)),
        body: LoadingView(message: l10n.loading),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetailTitle)),
        body: ErrorView(
          message: e.toString(),
          onRetry: () => ref
              .read(orderDetailControllerProvider(orderId).notifier)
              .refresh(),
        ),
      ),
      data: (order) => _OrderDetailBody(order: order),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  Future<void> _onEdit(BuildContext context, WidgetRef ref) async {
    final updated = await context.push<bool>(AppRoutes.orderEditFor(order.id));
    if (updated == true) {
      await ref
          .read(orderDetailControllerProvider(order.id).notifier)
          .refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.number,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
        ),
        actions: [
          if (order.isEditable)
            TextButton(
              onPressed: () => _onEdit(context, ref),
              child: Text(l10n.edit),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(orderDetailControllerProvider(order.id).notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPaddingH,
            AppSizes.sm,
            AppSizes.screenPaddingH,
            AppSizes.xxl,
          ),
          children: [
            _Hero(order: order),
            const SizedBox(height: AppSizes.xl),
            _InfoCard(
              title: l10n.quotationInfo,
              rows: [
                (label: l10n.date, value: AppFormatters.date(order.createdAt)),
                if (order.validityDate != null)
                  (
                    label: l10n.validityDate,
                    value: AppFormatters.date(order.validityDate!),
                  ),
                if (order.origin?.isNotEmpty == true)
                  (label: l10n.origin, value: order.origin!),
                if (order.clientOrderRef?.isNotEmpty == true)
                  (label: l10n.clientOrderRef, value: order.clientOrderRef!),
                if (order.opportunityName?.isNotEmpty == true)
                  (label: l10n.opportunity, value: order.opportunityName!),
              ],
            ),
            _InfoCard(
              title: l10n.salesInfo,
              rows: [
                if (order.salespersonName?.isNotEmpty == true)
                  (label: l10n.salesperson, value: order.salespersonName!),
                if (order.teamName?.isNotEmpty == true)
                  (label: l10n.salesTeam, value: order.teamName!),
                if (order.pricelistName?.isNotEmpty == true)
                  (label: l10n.pricelist, value: order.pricelistName!),
                if (order.paymentTermName?.isNotEmpty == true)
                  (label: l10n.paymentTerm, value: order.paymentTermName!),
              ],
            ),
            if (order.note?.isNotEmpty == true) ...[
              _SectionLabel(l10n.note),
              const SizedBox(height: AppSizes.sm),
              _PlainCard(
                child: Text(
                  order.note!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
            _SectionLabel(l10n.orderLines),
            const SizedBox(height: AppSizes.sm),
            if (order.lines.isEmpty)
              _PlainCard(
                child: Text(
                  l10n.noOrderLines,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              )
            else
              _PlainCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < order.lines.length; i++) ...[
                      _OrderLineRow(line: order.lines[i]),
                      if (i != order.lines.length - 1)
                        const Divider(
                          height: 1,
                          thickness: AppSizes.borderWidth,
                          color: AppColors.border,
                        ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.md),
            _TotalRow(amount: order.amount),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrderStatusChip.backgroundFor(order.status),
            shape: BoxShape.circle,
          ),
          child: Text(
            _initials(order.customer),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: OrderStatusChip.textColorFor(order.status),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          order.customer.isNotEmpty ? order.customer : '—',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          order.number,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSizes.md),
        OrderStatusChip(status: order.status),
        const SizedBox(height: AppSizes.lg),
        Text(
          AppFormatters.currency(order.amount, symbol: '\$'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
        ),
      ],
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

class _PlainCard extends StatelessWidget {
  const _PlainCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.md),
        child: child,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<({String label, String value})> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(title),
          const SizedBox(height: AppSizes.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.xs,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _InfoRow(label: rows[i].label, value: rows[i].value),
                    if (i != rows.length - 1)
                      const Divider(
                        height: 1,
                        thickness: AppSizes.borderWidth,
                        color: AppColors.border,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  const _OrderLineRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final subtotal =
        line.subtotal > 0 ? line.subtotal : line.quantity * line.priceUnit;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.productName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (line.description.isNotEmpty &&
              line.description != line.productName) ...[
            const SizedBox(height: 2),
            Text(
              line.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_qty(line.quantity)} × ${AppFormatters.currency(line.priceUnit, symbol: '\$')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              Text(
                AppFormatters.currency(subtotal, symbol: '\$'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _qty(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.total,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          AppFormatters.currency(amount, symbol: '\$'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}
