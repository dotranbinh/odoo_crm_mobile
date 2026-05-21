import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_credentials_store.dart';
import '../../../core/network/odoo_session.dart';
import '../../../core/mobile_ui/mobile_ui_config_service.dart';
import '../../../core/odoo/odoo_form_schema_service.dart';
import 'auth_controller.dart';

class AuthSessionService {
  AuthSessionService(this._ref);

  final Ref _ref;

  Future<void> expire() async {
    _ref.read(odooCredentialsStoreProvider).clear();
    _ref.read(odooFormSchemaServiceProvider).clearCache();
    _ref.read(mobileUiConfigServiceProvider).clearCache();
    await _ref.read(odooSessionStoreProvider).clear();
    _ref.read(authControllerProvider.notifier).onSessionExpired();
  }
}

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService(ref);
});
