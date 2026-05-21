import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'dio_client.dart';
import 'odoo_credentials_store.dart';
import 'odoo_url_resolver.dart';
import 'odoo_exception.dart';
import 'odoo_session.dart';
import 'odoo_session_cookie.dart';

/// Odoo HTTP client.
///
/// - **Web**: external `/jsonrpc` (uid + password, no cookies).
/// - **Mobile/Desktop**: `/web/session/*` (session cookies).
class OdooJsonRpcClient {
  OdooJsonRpcClient(
    this._dio,
    this._sessionStore,
    this._credentialsStore,
  );

  final Dio _dio;
  final OdooSessionStore _sessionStore;
  final OdooCredentialsStore _credentialsStore;

  bool get _useExternalRpc => kIsWeb;

  Map<String, dynamic> _envelope(Map<String, dynamic> params) => {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': params,
        'id': DateTime.now().millisecondsSinceEpoch,
      };

  Future<dynamic> _post(
    String path,
    Map<String, dynamic> params, {
    required String baseUrl,
  }) async {
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final url =
        '$normalizedBase${path.startsWith('/') ? path.substring(1) : path}';

    final response = await _dio.post<dynamic>(
      url,
      data: _envelope(params),
    );

    if (!_useExternalRpc) {
      _logCookieState('after $path', response.headers);
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw OdooException(message: 'Invalid response format');
    }

    if (data.containsKey('error')) {
      final ex = OdooException.fromResponse(data);
      if (ex.isSessionExpired) {
        await _sessionStore.clear();
        _credentialsStore.clear();
      }
      throw ex;
    }

    return data['result'];
  }

  Future<dynamic> _callExternal({
    required String baseUrl,
    required String service,
    required String method,
    required List<dynamic> args,
  }) =>
      _post(
        ApiEndpoints.externalJsonRpc,
        {
          'service': service,
          'method': method,
          'args': args,
        },
        baseUrl: baseUrl,
      );

  void _logCookieState(String when, Headers headers) {
    if (!kDebugMode) return;
    final cookies = OdooSessionCookie.setCookieHeaderValues(headers);
    final stored = _sessionStore.current.cookie;
    debugPrint(
      '[OdooSession] $when | set-cookie count=${cookies.length} '
      '| stored=${stored?.name ?? "none"}',
    );
  }

  Future<OdooSession> authenticate({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    if (_useExternalRpc) {
      return _authenticateExternal(
        baseUrl: baseUrl,
        db: db,
        login: login,
        password: password,
      );
    }
    return _authenticateWebSession(
      baseUrl: baseUrl,
      db: db,
      login: login,
      password: password,
    );
  }

  Future<OdooSession> _authenticateExternal({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    final normalizedUrl = _normalizeUrl(baseUrl);

    final uidRaw = await _callExternal(
      baseUrl: normalizedUrl,
      service: 'common',
      method: 'authenticate',
      args: [db, login, password, <String, dynamic>{}],
    );

    final uid = uidRaw is int ? uidRaw : 0;
    if (uid <= 0) {
      throw OdooException(message: 'Invalid credentials');
    }

    _credentialsStore.setPassword(password);

    String? name = login;
    String? email;
    String? companyName;

    try {
      final users = await _callExternal(
        baseUrl: normalizedUrl,
        service: 'object',
        method: 'execute_kw',
        args: [
          db,
          uid,
          password,
          'res.users',
          'read',
          [
            [uid],
            ['name', 'login', 'email', 'company_id'],
          ],
          <String, dynamic>{},
        ],
      );
      if (users is List && users.isNotEmpty) {
        final u = users.first as Map<String, dynamic>;
        name = u['name']?.toString() ?? login;
        email = u['email']?.toString() ?? u['login']?.toString();
        companyName = _extractMany2oneName(u['company_id']);
      }
    } catch (_) {
      // Non-fatal — profile fields optional.
    }

    if (kDebugMode) {
      debugPrint('[OdooSession] external auth uid=$uid (web/jsonrpc)');
    }

    final session = OdooSession(
      serverUrl: normalizedUrl,
      db: db,
      uid: uid,
      login: login,
      name: name,
      email: email,
      companyName: companyName,
    );

    await _sessionStore.save(session);
    return session;
  }

  Future<OdooSession> _authenticateWebSession({
    required String baseUrl,
    required String db,
    required String login,
    required String password,
  }) async {
    final normalizedUrl = _normalizeUrl(baseUrl);

    final authPath = ApiEndpoints.authenticate.startsWith('/')
        ? ApiEndpoints.authenticate.substring(1)
        : ApiEndpoints.authenticate;

    final response = await _dio.post<dynamic>(
      '$normalizedUrl$authPath',
      data: _envelope({
        'db': db,
        'login': login,
        'password': password,
      }),
    );

    _logCookieState('after authenticate', response.headers);

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw OdooException(message: 'Authentication failed');
    }

    if (data.containsKey('error')) {
      throw OdooException.fromResponse(data);
    }

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw OdooException(message: 'Authentication failed');
    }

    final uidRaw = result['uid'];
    final uid = uidRaw is int ? uidRaw : 0;
    if (uid <= 0) {
      throw OdooException(message: 'Invalid credentials');
    }

    final cookieFromHeaders = OdooSessionCookie.fromSetCookieHeaders(
      OdooSessionCookie.setCookieHeaderValues(response.headers),
    );

    final legacySessionId = _parseLegacySessionId(result['session_id']);

    final cookie = cookieFromHeaders ??
        (legacySessionId != null
            ? OdooSessionCookie(
                name: OdooSessionCookie.legacySessionIdName,
                value: legacySessionId,
              )
            : null);

    if (kDebugMode) {
      debugPrint(
        '[OdooSession] web session auth uid=$uid cookie=${cookie?.name ?? "MISSING"}',
      );
    }

    final session = OdooSession(
      serverUrl: normalizedUrl,
      db: db,
      uid: uid,
      login: login,
      sessionId: legacySessionId,
      cookieName: cookie?.name,
      cookieValue: cookie?.value,
      companyId:
          result['company_id'] is int ? result['company_id'] as int : null,
      serverVersion: result['server_version']?.toString(),
      name: result['name']?.toString() ?? login,
      email: result['email']?.toString(),
      companyName: _extractMany2oneName(result['company_name']),
    );

    await _sessionStore.save(session);
    await _verifyWebSession();
    return session;
  }

  Future<void> _verifyWebSession() async {
    final session = _sessionStore.current;
    if (!session.isAuthenticated) {
      throw OdooException(message: 'Not authenticated');
    }

    try {
      await _post(
        ApiEndpoints.getSessionInfo,
        {},
        baseUrl: session.serverUrl,
      );
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await _sessionStore.clear();
        throw OdooException(
          message: 'Session could not be established with Odoo.',
        );
      }
      rethrow;
    }
  }

  String? _parseLegacySessionId(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'false') return null;
    return trimmed;
  }

  Future<void> destroy() async {
    if (_useExternalRpc) {
      _credentialsStore.clear();
      await _sessionStore.clear();
      return;
    }

    final session = _sessionStore.current;
    if (!session.isAuthenticated) return;

    try {
      await _post(
        ApiEndpoints.destroy,
        {},
        baseUrl: session.serverUrl,
      );
    } finally {
      _credentialsStore.clear();
      await _sessionStore.clear();
    }
  }

  Future<dynamic> callKw({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    final session = _sessionStore.current;
    if (!session.isAuthenticated) {
      throw OdooException(message: 'Not authenticated');
    }

    if (_useExternalRpc) {
      return _callKwExternal(
        session: session,
        model: model,
        method: method,
        args: args,
        kwargs: kwargs,
      );
    }

    return _post(
      ApiEndpoints.callKw,
      {
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      },
      baseUrl: session.serverUrl,
    );
  }

  Future<dynamic> _callKwExternal({
    required OdooSession session,
    required String model,
    required String method,
    required List<dynamic> args,
    required Map<String, dynamic> kwargs,
  }) async {
    final password = _credentialsStore.password;
    if (password == null || password.isEmpty) {
      throw OdooException(
        message: 'Session expired. Please sign in again.',
      );
    }

    return _callExternal(
      baseUrl: session.serverUrl,
      service: 'object',
      method: 'execute_kw',
      args: [
        session.db,
        session.uid,
        password,
        model,
        method,
        args,
        kwargs,
      ],
    );
  }

  String _normalizeUrl(String url) => OdooUrlResolver.normalize(url);

  String? _extractMany2oneName(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString();
    }
    return value?.toString();
  }
}

final odooJsonRpcClientProvider = Provider<OdooJsonRpcClient>((ref) {
  return OdooJsonRpcClient(
    ref.watch(dioProvider),
    ref.watch(odooSessionStoreProvider),
    ref.watch(odooCredentialsStoreProvider),
  );
});
