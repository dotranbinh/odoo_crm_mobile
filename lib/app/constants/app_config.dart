/// App-wide feature flags and Odoo defaults.
abstract final class AppConfig {
  /// When true, auth and leads use live Odoo JSON-RPC.
  static const bool useRealApi = true;

  /// Skip login screen with mock user (only when [useRealApi] is false).
  static const bool autoLoginMock = false;

  /// Local Odoo from [crm_odoo_mobile/docker-compose.yml] (override via `--dart-define`).
  static const defaultOdooUrl = String.fromEnvironment(
    'ODOO_URL',
    defaultValue: 'http://localhost:8069',
  );
  static const defaultOdooDb = String.fromEnvironment(
    'ODOO_DB',
    defaultValue: 'dev1',
  );

  /// Load layouts from Odoo addon `crm_mobile_ui` (menu: **Mobile App UI**).
  static const bool useMobileUiConfig = true;

  /// Fall back to get_views XML parser when layout version is 0.
  static const bool mobileUiFallbackToFormXml = true;
}
