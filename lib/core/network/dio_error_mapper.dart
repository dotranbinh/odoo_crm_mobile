import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Maps low-level HTTP errors to user-facing messages.
abstract final class DioErrorMapper {
  static String message(Object error) {
    if (error is DioException) {
      return _fromDio(error);
    }
    return error.toString();
  }

  static String _fromDio(DioException e) {
    final raw = e.message ?? '';
    final isCorsLike = kIsWeb &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown ||
            raw.contains('XMLHttpRequest') ||
            raw.contains('onError callback'));

    if (isCorsLike) {
      return 'Không kết nối được Odoo từ trình duyệt (lỗi CORS). '
          'Cách xử lý:\n'
          '• Nâng cấp module CRM Mobile UI trên Odoo (đã bật CORS), rồi restart Odoo\n'
          '• Hoặc chạy app desktop: flutter run -d macos\n'
          '• Hoặc Chrome dev: flutter run -d chrome '
          '--web-browser-flag=--disable-web-security '
          '--web-browser-flag=--user-data-dir=/tmp/chrome_cors_dev';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối Odoo quá thời gian. Kiểm tra URL và server đang chạy.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Không kết nối được Odoo. Kiểm tra URL (http://localhost:8069) và Docker.';
    }

    return raw.isNotEmpty ? raw : 'Network request failed';
  }
}
