import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_repository.dart';
import '../domain/lead_detail_view_data.dart';

final editLeadViewControllerProvider =
    AsyncNotifierProviderFamily<EditLeadViewController, LeadDetailViewData, int>(
  EditLeadViewController.new,
);

/// Loads lead record values using the **form** layout field list (for Edit Lead).
class EditLeadViewController extends FamilyAsyncNotifier<LeadDetailViewData, int> {
  @override
  Future<LeadDetailViewData> build(int arg) => _load(arg);

  Future<LeadDetailViewData> _load(int id) async {
    try {
      return await ref.read(leadRepositoryProvider).fetchLeadEditViewData(id);
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
