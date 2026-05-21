abstract final class ApiEndpoints {
  /// Web client session API (cookies) — used on mobile/desktop.
  static const authenticate = '/web/session/authenticate';
  static const destroy = '/web/session/destroy';
  static const callKw = '/web/dataset/call_kw';
  static const getSessionInfo = '/web/session/get_session_info';

  /// External JSON-RPC API (uid + password) — used on Flutter Web.
  static const externalJsonRpc = '/jsonrpc';
}
