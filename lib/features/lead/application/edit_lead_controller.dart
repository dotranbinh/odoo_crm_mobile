import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_repository.dart';
import '../domain/lead_update_input.dart';
import 'edit_lead_view_controller.dart';
import 'lead_detail_controller.dart';
import 'lead_list_controller.dart';

class EditLeadState {
  const EditLeadState({this.isSaving = false, this.error});

  final bool isSaving;
  final String? error;

  EditLeadState copyWith({bool? isSaving, String? error, bool clearError = false}) =>
      EditLeadState(
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : (error ?? this.error),
      );
}

class EditLeadController extends Notifier<EditLeadState> {
  @override
  EditLeadState build() => const EditLeadState();

  Future<bool> saveValues({
    required int leadId,
    required Map<String, dynamic> formValues,
  }) async {
    state = const EditLeadState(isSaving: true);
    try {
      await ref.read(leadRepositoryProvider).updateLeadFromValues(
            id: leadId,
            formValues: formValues,
          );
      ref.invalidate(leadDetailControllerProvider(leadId));
      ref.invalidate(editLeadViewControllerProvider(leadId));
      await ref.read(leadListControllerProvider.notifier).refresh();
      state = const EditLeadState();
      return true;
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = EditLeadState(
        isSaving: false,
        error: e.isSessionExpired
            ? 'Session expired. Please sign in again.'
            : e.message,
      );
      return false;
    } catch (e) {
      state = EditLeadState(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> save({
    required int leadId,
    required LeadUpdateInput input,
  }) async {
    state = const EditLeadState(isSaving: true);
    try {
      await ref.read(leadRepositoryProvider).updateLead(
            id: leadId,
            input: input,
          );
      ref.invalidate(leadDetailControllerProvider(leadId));
      ref.invalidate(editLeadViewControllerProvider(leadId));
      await ref.read(leadListControllerProvider.notifier).refresh();
      state = const EditLeadState();
      return true;
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = EditLeadState(
        isSaving: false,
        error: e.isSessionExpired
            ? 'Session expired. Please sign in again.'
            : e.message,
      );
      return false;
    } catch (e) {
      state = EditLeadState(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final editLeadControllerProvider =
    NotifierProvider<EditLeadController, EditLeadState>(
  EditLeadController.new,
);
