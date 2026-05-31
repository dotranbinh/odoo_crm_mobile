import '../odoo/odoo_field_definition.dart';
import '../odoo/odoo_field_group.dart';
import '../odoo/odoo_form_schema.dart';
import 'mobile_ui_schema.dart';

abstract final class MobileUiSchemaMapper {
  static OdooFormSchema toOdooFormSchema(MobileUiLayoutSchema layout) {
    final fields = <String, OdooFieldDefinition>{};
    final groups = <OdooFieldGroup>[];

    for (final section in layout.sections) {
      final names = <String>[];
      for (final f in section.fields) {
        names.add(f.name);
        fields[f.name] = OdooFieldDefinition(
          name: f.name,
          type: f.type == 'float' ? 'monetary' : f.type,
          label: f.label,
          relation: f.relation,
          widget: f.widget,
          selection: f.selection,
          readonly: f.readonly,
          required: f.required,
          showIfEmpty: f.showIfEmpty,
        );
      }
      if (names.isNotEmpty) {
        groups.add(OdooFieldGroup(title: section.title, fieldNames: names));
      }
    }

    return OdooFormSchema(
      model: layout.model,
      groups: groups,
      fields: fields,
      otherInfoTitle: layout.otherInfoTitle,
    );
  }

}
