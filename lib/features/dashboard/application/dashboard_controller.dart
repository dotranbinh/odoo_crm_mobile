import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_data.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardData>(
  DashboardController.new,
);

class DashboardController extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() => _load();

  Future<DashboardData> _load() async {
    try {
      return await ref.read(dashboardRepositoryProvider).fetchDashboard();
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
