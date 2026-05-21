class OdooException implements Exception {
  OdooException({
    required this.message,
    this.code,
    this.name,
    this.debug,
  });

  factory OdooException.fromResponse(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is! Map<String, dynamic>) {
      return OdooException(message: 'Unknown Odoo error');
    }

    final data = error['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return OdooException(
      code: error['code'] as int?,
      message: (dataMap['message'] ?? error['message'] ?? 'Odoo request failed')
          .toString(),
      name: dataMap['name']?.toString(),
      debug: dataMap['debug']?.toString(),
    );
  }

  final int? code;
  final String message;
  final String? name;
  final String? debug;

  bool get isAccessDenied =>
      name == 'odoo.exceptions.AccessDenied' ||
      message.toLowerCase().contains('access denied');

  bool get isSessionExpired =>
      name == 'odoo.http.SessionExpiredException' ||
      message.toLowerCase().contains('session expired');

  @override
  String toString() => 'OdooException: $message';
}
