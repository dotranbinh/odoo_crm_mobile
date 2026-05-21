import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import 'odoo_session_cookie.dart';

class OdooSession {
  const OdooSession({
    required this.serverUrl,
    required this.db,
    required this.uid,
    required this.login,
    this.sessionId,
    this.cookieName,
    this.cookieValue,
    this.companyId,
    this.serverVersion,
    this.name,
    this.email,
    this.companyName,
  });

  final String serverUrl;
  final String db;
  final int uid;
  final String login;
  final String? sessionId;
  final String? cookieName;
  final String? cookieValue;
  final int? companyId;
  final String? serverVersion;
  final String? name;
  final String? email;
  final String? companyName;

  bool get isAuthenticated => uid > 0;

  OdooSessionCookie? get cookie {
    final name = cookieName ??
        (sessionId != null ? OdooSessionCookie.legacySessionIdName : null);
    final value = cookieValue ?? sessionId;
    if (name == null || value == null) return null;
    final c = OdooSessionCookie(name: name, value: value);
    return c.isValid ? c : null;
  }

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'db': db,
        'uid': uid,
        'login': login,
        'sessionId': sessionId,
        'cookieName': cookieName,
        'cookieValue': cookieValue,
        'companyId': companyId,
        'serverVersion': serverVersion,
        'name': name,
        'email': email,
        'companyName': companyName,
      };

  factory OdooSession.fromJson(Map<String, dynamic> json) => OdooSession(
        serverUrl: json['serverUrl'] as String? ?? '',
        db: json['db'] as String? ?? '',
        uid: json['uid'] as int? ?? 0,
        login: json['login'] as String? ?? '',
        sessionId: _sanitizeCookieValue(json['sessionId']),
        cookieName: json['cookieName'] as String?,
        cookieValue: _sanitizeCookieValue(json['cookieValue'] ?? json['sessionId']),
        companyId: json['companyId'] as int?,
        serverVersion: json['serverVersion'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        companyName: json['companyName'] as String?,
      );

  OdooSession copyWith({
    String? serverUrl,
    String? db,
    int? uid,
    String? login,
    String? sessionId,
    String? cookieName,
    String? cookieValue,
    int? companyId,
    String? serverVersion,
    String? name,
    String? email,
    String? companyName,
  }) =>
      OdooSession(
        serverUrl: serverUrl ?? this.serverUrl,
        db: db ?? this.db,
        uid: uid ?? this.uid,
        login: login ?? this.login,
        sessionId: sessionId ?? this.sessionId,
        cookieName: cookieName ?? this.cookieName,
        cookieValue: cookieValue ?? this.cookieValue,
        companyId: companyId ?? this.companyId,
        serverVersion: serverVersion ?? this.serverVersion,
        name: name ?? this.name,
        email: email ?? this.email,
        companyName: companyName ?? this.companyName,
      );

  static const empty = OdooSession(
    serverUrl: '',
    db: '',
    uid: 0,
    login: '',
  );
}

String? _sanitizeCookieValue(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == 'false' || trimmed == 'null') {
    return null;
  }
  return trimmed;
}

class OdooSessionStore {
  OdooSessionStore(this._storage);

  static const _key = 'odoo_session';

  final SecureStorageService _storage;
  OdooSession _session = OdooSession.empty;

  OdooSession get current => _session;

  Future<void> load() async {
    final raw = await _storage.read(_key);
    if (raw != null && raw.isNotEmpty) {
      _session = OdooSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
  }

  Future<void> save(OdooSession session) async {
    _session = session;
    await _storage.write(_key, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    _session = OdooSession.empty;
    await _storage.delete(_key);
  }
}

final odooSessionStoreProvider = Provider<OdooSessionStore>((ref) {
  final store = OdooSessionStore(ref.watch(secureStorageProvider));
  return store;
});
