import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../odoo_session.dart';
import '../odoo_session_cookie.dart';

typedef OnSessionExpired = void Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required OdooSessionStore sessionStore,
    this.onSessionExpired,
  }) : _sessionStore = sessionStore;

  final OdooSessionStore _sessionStore;
  final OnSessionExpired? onSessionExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _sessionStore.current;
    if (session.serverUrl.isNotEmpty) {
      options.baseUrl = session.serverUrl;
    }

    final cookie = session.cookie;

    if (kIsWeb) {
      // Web: external /jsonrpc — no cookies; see dio_web_adapter_web.dart.
      handler.next(options);
      return;
    }

    // Native: CookieJar may not capture odoo-session-cookie — set explicitly.
    if (cookie != null) {
      options.headers['Cookie'] = cookie.headerValue;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _captureCookieFromResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _captureCookieFromResponse(err.response!);
    }

    final status = err.response?.statusCode;
    final data = err.response?.data;
    final isSessionError = status == 401 ||
        (data is Map<String, dynamic> &&
            data['error'] is Map &&
            (data['error'] as Map)['message']
                .toString()
                .toLowerCase()
                .contains('session'));

    if (isSessionError) {
      _sessionStore.clear();
      onSessionExpired?.call();
    }
    handler.next(err);
  }

  void _captureCookieFromResponse(Response<dynamic> response) {
    final parsed = OdooSessionCookie.fromSetCookieHeaders(
      OdooSessionCookie.setCookieHeaderValues(response.headers),
    );
    if (parsed == null) return;

    final current = _sessionStore.current;
    if (!current.isAuthenticated) return;

    final existing = current.cookie;
    if (existing?.name == parsed.name && existing?.value == parsed.value) {
      return;
    }

    _sessionStore.save(
      current.copyWith(
        cookieName: parsed.name,
        cookieValue: parsed.value,
        sessionId: parsed.name == OdooSessionCookie.legacySessionIdName
            ? parsed.value
            : current.sessionId,
      ),
    );
  }
}
