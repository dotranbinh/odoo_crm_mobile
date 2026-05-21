import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Resolves Odoo base URLs for the current platform (e.g. Android emulator).
abstract final class OdooUrlResolver {
  /// On Android emulator, `localhost` points to the emulator itself.
  /// Map it to `10.0.2.2` so the app reaches Odoo on the host machine.
  static String resolve(String url) {
    if (kIsWeb) return url;

    final uri = Uri.tryParse(url.trim());
    if (uri == null) return url;

    final host = uri.host.toLowerCase();
    if (!_isLocalHost(host)) return url;

    try {
      if (Platform.isAndroid) {
        return uri.replace(host: '10.0.2.2').toString();
      }
    } catch (_) {
      // Platform not available (e.g. some test environments).
    }

    return url;
  }

  static String normalize(String url) {
    var normalized = url.trim();
    if (normalized.isEmpty) return normalized;
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }
    if (!normalized.endsWith('/')) {
      normalized = '$normalized/';
    }
    return resolve(normalized);
  }

  static bool _isLocalHost(String host) =>
      host == 'localhost' || host == '127.0.0.1' || host == '::1';
}
