import 'package:flutter_test/flutter_test.dart';

import 'package:odoo_crm_mobile/core/odoo/odoo_write_format.dart';

void main() {
  group('OdooWriteFormat', () {
    test('dateTimeUtc uses Odoo datetime pattern', () {
      final dt = DateTime.utc(2026, 6, 22, 10, 30, 45);
      expect(OdooWriteFormat.dateTimeUtc(dt), '2026-06-22 10:30:45');
    });

    test('dateTimeUtc converts local time to UTC', () {
      final dt = DateTime(2026, 6, 22, 17, 30, 0); // local
      final expected = DateTime(2026, 6, 22, 17, 30, 0).toUtc();
      expect(
        OdooWriteFormat.dateTimeUtc(dt),
        '${expected.year.toString().padLeft(4, '0')}-'
        '${expected.month.toString().padLeft(2, '0')}-'
        '${expected.day.toString().padLeft(2, '0')} '
        '${expected.hour.toString().padLeft(2, '0')}:'
        '${expected.minute.toString().padLeft(2, '0')}:'
        '${expected.second.toString().padLeft(2, '0')}',
      );
    });

    test('date uses YYYY-MM-DD', () {
      expect(OdooWriteFormat.date(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
