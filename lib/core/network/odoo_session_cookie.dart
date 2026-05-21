import 'package:dio/dio.dart';

/// Parsed HTTP session cookie from Odoo (17+ uses [odooSessionCookieName]).
class OdooSessionCookie {
  const OdooSessionCookie({
    required this.name,
    required this.value,
  });

  static const odooSessionCookieName = 'odoo-session-cookie';
  static const legacySessionIdName = 'session_id';

  final String name;
  final String value;

  bool get isValid =>
      value.isNotEmpty && value != 'false' && value != 'null';

  String get headerValue => '$name=$value';

  /// Prefer Odoo 17+ cookie, then legacy session_id.
  static OdooSessionCookie? fromSetCookieHeaders(List<String> headers) {
    OdooSessionCookie? legacy;

    for (final header in headers) {
      final odooMatch = RegExp(
        '$odooSessionCookieName=([^;\\s,]+)',
        caseSensitive: false,
      ).firstMatch(header);
      if (odooMatch != null) {
        final value = odooMatch.group(1)?.trim();
        if (value != null && value.isNotEmpty && value != 'false') {
          return OdooSessionCookie(
            name: odooSessionCookieName,
            value: value,
          );
        }
      }

      final sessionMatch = RegExp(
        '$legacySessionIdName=([^;\\s,]+)',
        caseSensitive: false,
      ).firstMatch(header);
      if (sessionMatch != null) {
        final value = sessionMatch.group(1)?.trim();
        if (value != null && value.isNotEmpty && value != 'false') {
          legacy = OdooSessionCookie(
            name: legacySessionIdName,
            value: value,
          );
        }
      }
    }

    return legacy;
  }

  static List<String> setCookieHeaderValues(Headers headers) {
    final direct = headers['set-cookie'];
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    // Some adapters expose Set-Cookie differently.
    final values = <String>[];
    headers.map.forEach((key, list) {
      if (key.toLowerCase() == 'set-cookie') {
        values.addAll(list);
      }
    });
    return values;
  }
}
