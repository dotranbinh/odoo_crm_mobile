import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_json_rpc_client.dart';
import '../domain/order.dart';

class OrderRepository {
  OrderRepository(this._rpc);

  // ignore: unused_field — wired when switching to _fetchRemote()
  final OdooJsonRpcClient _rpc;

  Future<List<Order>> fetchOrders({
    OrderStatus? status,
    String? query,
  }) =>
      _fetchMock(status: status, query: query);

  Future<List<Order>> _fetchMock({
    OrderStatus? status,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final all = [
      Order(
        id: 1,
        number: 'SO-2024-001',
        customer: 'Nguyen Van A',
        amount: 12500,
        currency: 'USD',
        status: OrderStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 2,
        number: 'SO-2024-002',
        customer: 'Tran Thi B',
        amount: 28750,
        currency: 'USD',
        status: OrderStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Order(
        id: 3,
        number: 'SO-2024-003',
        customer: 'Le Van C',
        amount: 54200,
        currency: 'USD',
        status: OrderStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Order(
        id: 4,
        number: 'SO-2024-004',
        customer: 'Pham Thi D',
        amount: 8900,
        currency: 'USD',
        status: OrderStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Order(
        id: 5,
        number: 'SO-2024-005',
        customer: 'Hoang Van E',
        amount: 156000,
        currency: 'USD',
        status: OrderStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    var filtered = all;
    if (status != null) {
      filtered = filtered.where((o) => o.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered
          .where(
            (o) =>
                o.number.toLowerCase().contains(q) ||
                o.customer.toLowerCase().contains(q),
          )
          .toList();
    }
    return filtered;
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(odooJsonRpcClientProvider));
});
