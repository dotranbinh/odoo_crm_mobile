/// Formats values for Odoo JSON-RPC `create` / `write` calls.
abstract final class OdooWriteFormat {
  /// Odoo `fields.Date` — `YYYY-MM-DD`.
  static String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Odoo `fields.Datetime` — `YYYY-MM-DD HH:MM:SS` (UTC).
  static String dateTimeUtc(DateTime d) {
    final v = d.toUtc();
    return '${date(v)} '
        '${v.hour.toString().padLeft(2, '0')}:'
        '${v.minute.toString().padLeft(2, '0')}:'
        '${v.second.toString().padLeft(2, '0')}';
  }
}
