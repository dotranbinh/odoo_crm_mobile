import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../../lead/application/lead_list_controller.dart';
import '../../lead/data/lead_repository.dart';
import '../../lead/domain/lead.dart';

class CreateLeadState {
  const CreateLeadState({this.isSaving = false, this.error});

  final bool isSaving;
  final String? error;

  CreateLeadState copyWith({bool? isSaving, String? error, bool clearError = false}) =>
      CreateLeadState(
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : (error ?? this.error),
      );
}

class CreateLeadController extends Notifier<CreateLeadState> {
  @override
  CreateLeadState build() => const CreateLeadState();

  Future<Lead?> saveValues({required Map<String, dynamic> formValues}) async {
    state = const CreateLeadState(isSaving: true);
    try {
      final lead = await ref.read(leadRepositoryProvider).createLeadFromValues(
            formValues,
          );
      await ref.read(leadListControllerProvider.notifier).refresh();
      state = const CreateLeadState();
      return lead;
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = CreateLeadState(
        isSaving: false,
        error: e.isSessionExpired
            ? 'Session expired. Please sign in again.'
            : e.message,
      );
      return null;
    } catch (e) {
      state = CreateLeadState(isSaving: false, error: e.toString());
      return null;
    }
  }
}

final createLeadControllerProvider =
    NotifierProvider<CreateLeadController, CreateLeadState>(
  CreateLeadController.new,
);
