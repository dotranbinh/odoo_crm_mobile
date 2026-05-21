import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateLeadState {
  const CreateLeadState({this.isSaving = false});

  final bool isSaving;
}

class CreateLeadController extends Notifier<CreateLeadState> {
  @override
  CreateLeadState build() => const CreateLeadState();

  Future<bool> save({
    required String customerName,
    required String phone,
    String? email,
    String? source,
    String? note,
  }) async {
    state = const CreateLeadState(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = const CreateLeadState();
    return true;
  }
}

final createLeadControllerProvider =
    NotifierProvider<CreateLeadController, CreateLeadState>(
  CreateLeadController.new,
);
