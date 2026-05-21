import 'odoo_field_definition.dart';
import 'odoo_field_group.dart';

class OdooFormSchema {
  const OdooFormSchema({
    required this.model,
    required this.groups,
    required this.fields,
    this.otherInfoTitle = 'Other Information',
  });

  final String model;
  final List<OdooFieldGroup> groups;
  final Map<String, OdooFieldDefinition> fields;
  final String otherInfoTitle;

  /// Field names to fetch via [read] — only fields shown in [displayGroups].
  List<String> get readableFieldNames {
    final names = <String>{'id'};
    for (final group in displayGroups) {
      names.addAll(group.fieldNames);
    }
    return names.toList();
  }

  /// All field names appearing on the form arch (excludes Other Info x_* only).
  Set<String> get archFieldNames => groups
      .where((g) => g.title != otherInfoTitle)
      .expand((g) => g.fieldNames)
      .toSet();

  Set<String> get customFieldNames => groups
      .where((g) => g.title == otherInfoTitle)
      .expand((g) => g.fieldNames)
      .toSet();

  OdooFieldDefinition? fieldDef(String name) => fields[name];

  Iterable<OdooFieldGroup> get displayGroups => groups
      .map(
        (g) => OdooFieldGroup(
          title: g.title,
          fieldNames: g.fieldNames
              .where((n) {
                final def = fields[n];
                return def != null && def.isDisplayable;
              })
              .toList(),
        ),
      )
      .where((g) => g.fieldNames.isNotEmpty);
}
