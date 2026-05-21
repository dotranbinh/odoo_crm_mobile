import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_session_service.dart';
import 'dio_web_adapter_stub.dart'
    if (dart.library.html) 'dio_web_adapter_web.dart' as web_adapter;
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'odoo_session.dart';

Dio createDio({
  required OdooSessionStore sessionStore,
  void Function()? onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  if (kIsWeb) {
    web_adapter.applyWebAdapter(dio);
  }

  final interceptors = <Interceptor>[
    AuthInterceptor(
      sessionStore: sessionStore,
      onSessionExpired: onSessionExpired,
    ),
    LoggerInterceptor(),
  ];

  if (!kIsWeb) {
    interceptors.insert(0, CookieManager(CookieJar()));
  }

  dio.interceptors.addAll(interceptors);

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final sessionStore = ref.watch(odooSessionStoreProvider);
  return createDio(
    sessionStore: sessionStore,
    onSessionExpired: () {
      ref.read(authSessionServiceProvider).expire();
    },
  );
});
