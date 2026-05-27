import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_chatter_repository.dart';
import '../domain/mail_message.dart';

final leadChatterControllerProvider =
    AsyncNotifierProviderFamily<LeadChatterController, List<MailMessage>, int>(
  LeadChatterController.new,
);

class LeadChatterController extends FamilyAsyncNotifier<List<MailMessage>, int> {
  @override
  Future<List<MailMessage>> build(int arg) => _load(arg);

  Future<List<MailMessage>> _load(int leadId) async {
    try {
      return await ref.read(leadChatterRepositoryProvider).fetchMessages(leadId);
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

  Future<bool> postLogNote(String body) => _post(
        body: body,
        post: (leadId, text) => ref
            .read(leadChatterRepositoryProvider)
            .postLogNote(leadId: leadId, body: text),
      );

  Future<bool> postDiscussion(String body) => _post(
        body: body,
        post: (leadId, text) => ref
            .read(leadChatterRepositoryProvider)
            .postDiscussion(leadId: leadId, body: text),
      );

  Future<bool> _post({
    required String body,
    required Future<void> Function(int leadId, String body) post,
  }) async {
    final text = body.trim();
    if (text.isEmpty) return false;

    try {
      await post(arg, text);
      await refresh();
      return true;
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      rethrow;
    }
  }
}
