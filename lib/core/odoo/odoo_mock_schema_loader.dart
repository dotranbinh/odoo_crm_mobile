import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'odoo_field_definition.dart';
import 'odoo_field_group.dart';
import 'odoo_form_schema.dart';
import 'odoo_form_schema_parser.dart';

/// Loads mock form schema + record values from assets when [useRealApi] is false.
class OdooMockSchemaLoader {
  static const crmLeadModel = 'crm.lead';

  Future<OdooFormSchema> loadSchema({
    String model = crmLeadModel,
    String otherInfoTitle = 'Other Information',
  }) async {
    final path = model == crmLeadModel
        ? 'assets/mock/crm_lead_form_schema.json'
        : 'assets/mock/${model.replaceAll('.', '_')}_form_schema.json';

    try {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _schemaFromJson(json, otherInfoTitle: otherInfoTitle);
    } catch (_) {
      return _fallbackCrmLeadSchema(otherInfoTitle);
    }
  }

  Future<Map<String, dynamic>> loadRecordValues({
    required int id,
    String model = crmLeadModel,
  }) async {
    final path = model == crmLeadModel
        ? 'assets/mock/crm_lead_record_$id.json'
        : 'assets/mock/${model.replaceAll('.', '_')}_record_$id.json';

    try {
      final raw = await rootBundle.loadString(path);
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return _fallbackRecordValues(id);
    }
  }

  OdooFormSchema _schemaFromJson(
    Map<String, dynamic> json, {
    required String otherInfoTitle,
  }) {
    final model = json['model']?.toString() ?? crmLeadModel;
    final arch = json['arch']?.toString();
    final fieldsJson = json['fields'];
    if (arch != null && fieldsJson is Map) {
      return OdooFormSchemaParser(otherInfoTitle: otherInfoTitle).parse(
        model: model,
        archXml: arch,
        modelFieldsJson: Map<String, dynamic>.from(fieldsJson),
      );
    }

    final groupsJson = json['groups'] as List? ?? [];
    final fields = <String, OdooFieldDefinition>{};
    final fieldsMeta = json['fields'] as Map? ?? {};
    for (final entry in fieldsMeta.entries) {
      if (entry.value is Map) {
        fields[entry.key.toString()] = OdooFieldDefinition.fromJson(
          entry.key.toString(),
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }

    final groups = groupsJson
        .map((g) {
          final map = Map<String, dynamic>.from(g as Map);
          return OdooFieldGroup(
            title: map['title']?.toString() ?? '',
            fieldNames: (map['fields'] as List? ?? [])
                .map((e) => e.toString())
                .toList(),
          );
        })
        .where((g) => g.title.isNotEmpty)
        .toList();

    return OdooFormSchema(
      model: model,
      groups: groups,
      fields: fields,
      otherInfoTitle: otherInfoTitle,
    );
  }

  OdooFormSchema _fallbackCrmLeadSchema(String otherInfoTitle) {
    const arch = '''
<form>
  <sheet>
    <group string="Contact Information">
      <field name="partner_name"/>
      <field name="contact_name"/>
      <field name="phone"/>
      <field name="mobile"/>
      <field name="email_from"/>
      <field name="website"/>
      <field name="function"/>
      <field name="street"/>
      <field name="city"/>
    </group>
    <group string="Marketing">
      <field name="source_id"/>
      <field name="user_id"/>
    </group>
    <group string="Opportunity">
      <field name="name"/>
      <field name="stage_id"/>
      <field name="priority"/>
      <field name="expected_revenue"/>
      <field name="probability"/>
      <field name="date_deadline"/>
    </group>
    <group string="Notes">
      <field name="description"/>
    </group>
    <group string="Other Information">
      <field name="x_custom_note"/>
    </group>
  </sheet>
</form>
''';

    final fields = <String, dynamic>{
      'name': {'type': 'char', 'string': 'Opportunity'},
      'partner_name': {'type': 'char', 'string': 'Customer'},
      'contact_name': {'type': 'char', 'string': 'Contact Name'},
      'phone': {'type': 'char', 'string': 'Phone'},
      'mobile': {'type': 'char', 'string': 'Mobile'},
      'email_from': {'type': 'char', 'string': 'Email'},
      'website': {'type': 'char', 'string': 'Website'},
      'function': {'type': 'char', 'string': 'Job Position'},
      'street': {'type': 'char', 'string': 'Street'},
      'city': {'type': 'char', 'string': 'City'},
      'source_id': {'type': 'many2one', 'string': 'Source', 'relation': 'utm.source'},
      'user_id': {'type': 'many2one', 'string': 'Salesperson', 'relation': 'res.users'},
      'stage_id': {'type': 'many2one', 'string': 'Stage', 'relation': 'crm.stage'},
      'priority': {
        'type': 'selection',
        'string': 'Priority',
        'selection': [
          ['0', 'Low'],
          ['1', 'Normal'],
          ['2', 'High'],
          ['3', 'Very High'],
        ],
      },
      'expected_revenue': {'type': 'monetary', 'string': 'Expected Revenue'},
      'probability': {'type': 'float', 'string': 'Probability'},
      'date_deadline': {'type': 'date', 'string': 'Expected Closing'},
      'description': {'type': 'html', 'string': 'Notes'},
      'x_custom_note': {'type': 'char', 'string': 'Custom Note (Studio)'},
    };

    return OdooFormSchemaParser(otherInfoTitle: otherInfoTitle).parse(
      model: crmLeadModel,
      archXml: arch,
      modelFieldsJson: fields,
    );
  }

  Map<String, dynamic> _fallbackRecordValues(int id) {
    return {
      'id': id,
      'name': 'Opportunity #$id',
      'partner_name': 'Nguyen Van A',
      'contact_name': 'Nguyen Van A',
      'phone': '+84 901 234 567',
      'mobile': '+84 901 234 568',
      'email_from': 'nguyenvana@email.com',
      'website': 'https://example.com',
      'function': 'CEO',
      'street': '123 Le Loi',
      'city': 'Hanoi',
      'source_id': [1, 'Website'],
      'user_id': [2, 'John Smith'],
      'stage_id': [3, 'New'],
      'priority': '1',
      'expected_revenue': 25000.0,
      'probability': 40.0,
      'date_deadline': DateTime.now().add(const Duration(days: 14)).toIso8601String().split('T').first,
      'description': '<p>Discussing Q3 implementation timeline.</p>',
      'x_custom_note': 'VIP customer from trade show',
    };
  }
}

final odooMockSchemaLoaderProvider = Provider<OdooMockSchemaLoader>(
  (ref) => OdooMockSchemaLoader(),
);
