import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/order_list_controller.dart';
import '../domain/order.dart';
import 'widgets/order_card.dart';
import 'widgets/order_status_tabs.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(orderListControllerProvider);

    final tabLabels = <OrderStatus?, String>{
      null: l10n.all,
      OrderStatus.draft: l10n.draft,
      OrderStatus.sent: l10n.sent,
      OrderStatus.sale: l10n.sale,
      OrderStatus.cancel: l10n.cancelled,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    l10n.orders,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    '${state.orders.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SearchField(
                hint: l10n.searchOrders,
                onChanged: (q) => ref
                    .read(orderListControllerProvider.notifier)
                    .setQuery(q),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: OrderStatusTabs(
                selected: state.selectedStatus,
                labels: tabLabels,
                onSelected: (status) => ref
                    .read(orderListControllerProvider.notifier)
                    .setStatus(status),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Expanded(child: _buildBody(context, ref, state, l10n)),
          ],
        ),
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          0,
          AppSizes.md,
          AppSizes.xxl,
        ),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return OrderCard(
            order: order,
            onTap: () => context.push(AppRoutes.orderDetailFor(order.id)),
          );
        },
      ),
    );
  }
}
