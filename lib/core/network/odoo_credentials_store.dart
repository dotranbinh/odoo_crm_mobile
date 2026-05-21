import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory API password for external JSON-RPC (Web).
/// Never persisted — user re-authenticates after app restart.
class OdooCredentialsStore {
  String? _password;

  String? get password => _password;

  bool get hasPassword => _password != null && _password!.isNotEmpty;

  void setPassword(String password) => _password = password;

  void clear() => _password = null;
}

final odooCredentialsStoreProvider = Provider<OdooCredentialsStore>((ref) {
  return OdooCredentialsStore();
});
