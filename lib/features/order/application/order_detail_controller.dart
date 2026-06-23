import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

final orderDetailControllerProvider =
    AsyncNotifierProviderFamily<OrderDetailController, Order, int>(
  OrderDetailController.new,
);

class OrderDetailController extends FamilyAsyncNotifier<Order, int> {
  @override
  Future<Order> build(int arg) => _load(arg);

  Future<Order> _load(int id) async {
    try {
      return await ref.read(orderRepositoryProvider).fetchOrderById(id);
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }
}
