import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../../../core/network/odoo_url_resolver.dart';
import '../domain/user.dart';

class AuthRepository {
  AuthRepository(this._rpc);

  final OdooJsonRpcClient _rpc;

  static const mockUser = User(
    id: 1,
    name: 'Admin Demo',
    email: 'admin@acme.com',
    company: 'Acme Corporation',
  );

  Future<User> signIn({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    if (AppConfig.useRealApi) {
      return _signInRemote(
        baseUrl: baseUrl,
        db: db,
        login: login,
        password: password,
      );
    }
    return _signInMock(login: login);
  }

  Future<User> _signInRemote({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    final session = await _rpc.authenticate(
      baseUrl: OdooUrlResolver.normalize(baseUrl),
      db: db,
      login: login,
      password: password,
    );
    return User(
      id: session.uid,
      name: session.name ?? login,
      email: session.email ?? login,
      company: session.companyName ?? '',
    );
  }

  Future<User> _signInMock({required String login}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (login.isEmpty) return mockUser;
    return mockUser.copyWith(
      name: login,
      email: '$login@acme.com',
    );
  }

  Future<User> signInMockDemo() async => mockUser;

  Future<void> signOut() async {
    if (AppConfig.autoLoginMock && !AppConfig.useRealApi) return;
    await _rpc.destroy();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(odooJsonRpcClientProvider));
});
