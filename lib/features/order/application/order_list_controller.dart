import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/order_repository.dart';
import '../domain/order.dart';

class OrderListState {
  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
    this.query = '',
  });

  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final OrderStatus? selectedStatus;
  final String query;

  OrderListState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    OrderStatus? selectedStatus,
    String? query,
    bool clearStatus = false,
    bool clearError = false,
  }) =>
      OrderListState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        selectedStatus:
            clearStatus ? null : (selectedStatus ?? this.selectedStatus),
        query: query ?? this.query,
      );
}

class OrderListController extends Notifier<OrderListState> {
  @override
  OrderListState build() {
    Future.microtask(load);
    return const OrderListState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await ref.read(orderRepositoryProvider).fetchOrders(
            status: state.selectedStatus,
            query: state.query.isEmpty ? null : state.query,
          );
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setStatus(OrderStatus? status) {
    state = state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
    );
    load();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    load();
  }

  Future<void> refresh() => load();
}

final orderListControllerProvider =
    NotifierProvider<OrderListController, OrderListState>(
  OrderListController.new,
);
