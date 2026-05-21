import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_credentials_store.dart';
import '../../../core/mobile_ui/mobile_ui_config_service.dart';
import '../../../core/odoo/odoo_form_schema_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/odoo_exception.dart';
import '../../../core/network/odoo_session.dart';
import '../../../core/network/odoo_session_cookie.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isInitialized: isInitialized ?? this.isInitialized,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> initialize() async {
    final sessionStore = ref.read(odooSessionStoreProvider);
    await sessionStore.load();
    final session = sessionStore.current;

    // Web uses external JSON-RPC — password is in-memory only, not restored.
    final canRestoreSession = session.isAuthenticated &&
        (!kIsWeb || ref.read(odooCredentialsStoreProvider).hasPassword);

    if (canRestoreSession) {
      state = AuthState(
        isInitialized: true,
        user: User(
          id: session.uid,
          name: session.name ?? session.login,
          email: session.email ?? '',
          company: session.companyName ?? '',
        ),
      );
      return;
    }

    if (session.isAuthenticated && kIsWeb) {
      await sessionStore.clear();
    }

    if (AppConfig.autoLoginMock && !AppConfig.useRealApi) {
      await _autoLoginMock();
      return;
    }

    state = const AuthState(isInitialized: true);
  }

  Future<void> _autoLoginMock() async {
    final user = await ref.read(authRepositoryProvider).signInMockDemo();
    await ref.read(odooSessionStoreProvider).save(
          const OdooSession(
            serverUrl: AppConfig.defaultOdooUrl,
            db: AppConfig.defaultOdooDb,
            uid: 1,
            login: 'admin',
            cookieName: OdooSessionCookie.odooSessionCookieName,
            cookieValue: 'mock-session-id',
            companyId: 1,
            serverVersion: '17.0',
            name: 'Admin Demo',
            email: 'admin@acme.com',
            companyName: 'Acme Corporation',
          ),
        );
    state = AuthState(user: user, isInitialized: true);
  }

  void onSessionExpired() {
    state = const AuthState(isInitialized: true);
  }

  Future<bool> login({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).signIn(
            baseUrl: baseUrl,
            db: db,
            login: login,
            password: password,
          );
      ref.read(odooFormSchemaServiceProvider).clearCache();
      ref.read(mobileUiConfigServiceProvider).clearCache();
      state = AuthState(user: user, isInitialized: true);
      return true;
    } on OdooException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isInitialized: true,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: DioErrorMapper.message(e),
        isInitialized: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(odooCredentialsStoreProvider).clear();
    ref.read(odooFormSchemaServiceProvider).clearCache();
    ref.read(mobileUiConfigServiceProvider).clearCache();
    await ref.read(odooSessionStoreProvider).clear();
    state = const AuthState(isInitialized: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
