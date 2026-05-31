import '../odoo/odoo_many2many_enricher.dart';
import 'mobile_ui_schema.dart';

/// Converts form values to Odoo `write` payloads by field type.
abstract final class MobileUiWriteCoercer {
  static dynamic coerce(MobileUiFieldSchema field, dynamic value) {
    if (field.widget == 'tags') {
      return _many2manyReplace(value);
    }

    if (value == null || (value is String && value.isEmpty)) {
      return false;
    }

    switch (field.type) {
      case 'many2one':
        return _many2oneId(value) ?? false;
      case 'many2many':
      case 'one2many':
        return value;
      case 'boolean':
        return value == true || value == 'true' || value == 1 || value == '1';
      case 'integer':
        return int.tryParse(value.toString()) ?? false;
      case 'float':
      case 'monetary':
        return double.tryParse(value.toString()) ?? false;
      default:
        if (field.widget == 'number' || field.widget == 'currency') {
          return double.tryParse(value.toString()) ?? false;
        }
        return value;
    }
  }

  /// Odoo command `(6, 0, ids)` — replace all links.
  static List<List<dynamic>> _many2manyReplace(dynamic value) {
    final ids = Many2manyValueHelper.parseIds(value);
    return [
      [6, 0, ids],
    ];
  }

  static int? _many2oneId(dynamic value) {
    if (value is int) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is int) return first;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
