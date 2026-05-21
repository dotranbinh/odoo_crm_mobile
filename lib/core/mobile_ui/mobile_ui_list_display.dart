import 'package:flutter/material.dart';

import '../odoo/odoo_field_formatter.dart';
import '../odoo/odoo_field_definition.dart';
import 'mobile_ui_schema.dart';

class MobileUiListDisplay {
  const MobileUiListDisplay._();

  static String primaryTitle(MobileUiLayoutSchema layout, Map<String, dynamic> values) {
    final field = layout.listPrimaryField;
    if (field != null) {
      final def = _def(field);
      final text = OdooFieldFormatter.format(definition: def, value: values[field.name]);
      if (text != null && text.isNotEmpty) return text;
    }
    return values['partner_name']?.toString() ??
        values['name']?.toString() ??
        '';
  }

  static String? subtitle(MobileUiLayoutSchema layout, Map<String, dynamic> values) {
    final field = layout.listSubtitleField;
    if (field == null) return null;
    final def = _def(field);
    return OdooFieldFormatter.format(definition: def, value: values[field.name]);
  }

  static List<({IconData icon, String text})> lines(
    MobileUiLayoutSchema layout,
    Map<String, dynamic> values,
  ) {
    final rows = <({IconData icon, String text})>[];
    for (final field in layout.listLineFields) {
      final def = _def(field);
      final text = OdooFieldFormatter.format(
        definition: def,
        value: values[field.name],
      );
      if (text == null || text.isEmpty) continue;
      rows.add((icon: _icon(field.widget), text: text));
    }
    return rows;
  }

  static OdooFieldDefinition _def(MobileUiFieldSchema field) {
    return OdooFieldDefinition(
      name: field.name,
      type: field.type,
      label: field.label,
      selection: field.selection,
    );
  }

  static IconData _icon(String widget) => switch (widget) {
        'phone' => Icons.phone_outlined,
        'email' => Icons.email_outlined,
        'datetime' || 'date' => Icons.calendar_today_outlined,
        'many2one' || 'stage' => Icons.person_outline,
        _ => Icons.info_outline,
      };
}
