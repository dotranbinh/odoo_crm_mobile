import '../utils/formatters.dart';
import 'odoo_field_definition.dart';

abstract final class OdooFieldFormatter {
  static String? format({
    required OdooFieldDefinition definition,
    required dynamic value,
  }) {
    if (_isEmpty(value)) return null;

    switch (definition.type) {
      case 'boolean':
        return value == true ? 'Yes' : 'No';
      case 'integer':
        return value is num ? value.toInt().toString() : value.toString();
      case 'float':
      case 'monetary':
        if (value is num) {
          return definition.type == 'monetary'
              ? AppFormatters.currency(value.toDouble())
              : value.toString();
        }
        return value.toString();
      case 'date':
        if (value is String) {
          final d = DateTime.tryParse(value);
          return d != null ? AppFormatters.date(d) : value;
        }
        return value.toString();
      case 'datetime':
        if (value is String) {
          final d = DateTime.tryParse(value);
          return d != null ? AppFormatters.dateTime(d) : value;
        }
        return value.toString();
      case 'selection':
        return _selectionLabel(definition, value);
      case 'many2one':
        return _many2oneLabel(value);
      case 'many2many':
        return _many2manyLabel(value);
      case 'html':
        return stripHtml(value.toString());
      case 'text':
      case 'char':
      default:
        final raw = value.toString();
        if (isHtmlField(definition)) {
          return stripHtml(raw);
        }
        return raw;
    }
  }

  /// True when field stores Odoo HTML (notes / description).
  static bool isHtmlField(OdooFieldDefinition definition) =>
      definition.type == 'html' ||
      definition.widget == 'html' ||
      definition.name == 'description';

  /// Plain text from Odoo HTML (tags removed, entities decoded).
  static String stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n[ \t]+'), '\n');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is bool && !value) return true;
    if (value is String) {
      final t = value.trim();
      if (t.isEmpty) return true;
      // Odoo empty char/text is sometimes serialized as the string "false".
      if (t == 'false' || t == 'False') return true;
    }
    if (value is List && value.isEmpty) return true;
    return false;
  }

  static String? _selectionLabel(
    OdooFieldDefinition definition,
    dynamic value,
  ) {
    final key = value.toString();
    for (final pair in definition.selection) {
      if (pair.isNotEmpty && pair.first.toString() == key) {
        return pair.length > 1 ? pair[1].toString() : key;
      }
    }
    return key;
  }

  static String? _many2oneLabel(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString();
    }
    if (value is bool && !value) return null;
    return value?.toString();
  }

  static String? _many2manyLabel(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final names = <String>[];
    for (final item in value) {
      if (item is List && item.length > 1) {
        names.add(item[1].toString());
      } else if (item is String) {
        names.add(item);
      }
    }
    return names.isEmpty ? null : names.join(', ');
  }

}
