import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../application/order_list_controller.dart';
import '../domain/order.dart';
import 'widgets/order_card.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(orderListControllerProvider);

    final tabLabels = <OrderStatus?, String>{
      null: l10n.all,
      OrderStatus.draft: l10n.draft,
      OrderStatus.confirmed: l10n.confirmed,
      OrderStatus.done: l10n.done,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orders)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: SearchField(
              hint: l10n.searchOrders,
              onChanged: (q) => ref
                  .read(orderListControllerProvider.notifier)
                  .setQuery(q),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tabLabels.entries.map((entry) {
                  final isSelected = state.selectedStatus == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: StatusChip(
                      label: entry.value,
                      color: _colorFor(entry.key),
                      selected: isSelected,
                      onTap: () => ref
                          .read(orderListControllerProvider.notifier)
                          .setStatus(isSelected ? null : entry.key),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(child: _buildBody(context, ref, state, l10n)),
        ],
      ),
    );
  }

  Color _colorFor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.draft:
        return const Color(0xFF6B6B7B);
      case OrderStatus.confirmed:
        return const Color(0xFFFFC107);
      case OrderStatus.done:
        return const Color(0xFF28A745);
      case null:
        return const Color(0xFF714B67);
    }
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OrderListState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.orders.isEmpty) {
      return LoadingView(message: l10n.loading);
    }

    if (state.error != null && state.orders.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(orderListControllerProvider.notifier).refresh(),
      );
    }

    if (state.orders.isEmpty) {
      return EmptyState(
        title: l10n.noOrders,
        message: l10n.noOrdersMessage,
        icon: Icons.shopping_bag_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(orderListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: state.orders.length,
        itemBuilder: (context, index) =>
            OrderCard(order: state.orders[index]),
      ),
    );
  }
}
