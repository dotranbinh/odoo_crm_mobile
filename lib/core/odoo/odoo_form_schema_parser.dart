import 'package:xml/xml.dart';

import 'odoo_field_definition.dart';
import 'odoo_field_group.dart';
import 'odoo_form_schema.dart';

class OdooFormSchemaParser {
  const OdooFormSchemaParser({this.otherInfoTitle = 'Other Information'});

  final String otherInfoTitle;

  OdooFormSchema parse({
    required String model,
    required String archXml,
    required Map<String, dynamic> modelFieldsJson,
  }) {
    final allMeta = _parseAllFieldMeta(modelFieldsJson);
    final archFields = <String>{};
    final assignedFields = <String>{};
    final groupOrder = <String>[];
    final groupFieldsMap = <String, List<String>>{};

    final document = XmlDocument.parse(archXml);
    _visitElement(
      document.rootElement,
      currentGroup: null,
      groupOrder: groupOrder,
      groupFieldsMap: groupFieldsMap,
      archFields: archFields,
      assignedFields: assignedFields,
    );

    // Fields in arch but never assigned to a titled group (rare edge case).
    final unassigned = archFields.difference(assignedFields).toList();
    if (unassigned.isNotEmpty) {
      _ensureGroup(
        OdooFieldExclusions.defaultGroupTitle,
        groupOrder,
        groupFieldsMap,
      );
      for (final name in unassigned) {
        _addFieldToGroup(
          name,
          OdooFieldExclusions.defaultGroupTitle,
          groupOrder,
          groupFieldsMap,
          assignedFields,
        );
      }
    }

    final groups = <OdooFieldGroup>[];
    for (final title in groupOrder) {
      final names = groupFieldsMap[title];
      if (names != null && names.isNotEmpty) {
        groups.add(OdooFieldGroup(title: title, fieldNames: List.from(names)));
      }
    }

    // Other Information: only custom x_* / x_studio_* not already on the form.
    final otherFieldNames = allMeta.keys
        .where(OdooFieldExclusions.isCustomField)
        .where((name) => !archFields.contains(name))
        .where(
          (name) => OdooFieldExclusions.isDisplayableField(
            name,
            allMeta[name]!.type,
          ),
        )
        .toList()
      ..sort();

    if (otherFieldNames.isNotEmpty) {
      groups.add(OdooFieldGroup(
        title: otherInfoTitle,
        fieldNames: otherFieldNames,
      ));
    }

    final usedNames = <String>{
      ...archFields,
      ...otherFieldNames,
    };

    final fields = <String, OdooFieldDefinition>{};
    for (final name in usedNames) {
      final meta = allMeta[name];
      if (meta != null) {
        fields[name] = meta;
      }
    }

    return OdooFormSchema(
      model: model,
      groups: groups,
      fields: fields,
      otherInfoTitle: otherInfoTitle,
    );
  }

  Map<String, OdooFieldDefinition> _parseAllFieldMeta(
    Map<String, dynamic> modelFieldsJson,
  ) {
    final fields = <String, OdooFieldDefinition>{};
    for (final entry in modelFieldsJson.entries) {
      final meta = entry.value;
      if (meta is! Map<String, dynamic>) continue;
      fields[entry.key] = OdooFieldDefinition.fromJson(entry.key, meta);
    }
    return fields;
  }

  void _visitElement(
    XmlElement element, {
    required String? currentGroup,
    required List<String> groupOrder,
    required Map<String, List<String>> groupFieldsMap,
    required Set<String> archFields,
    required Set<String> assignedFields,
  }) {
    final tag = element.localName;

    if (OdooFieldExclusions.shouldSkipArchElement(tag)) {
      return;
    }

    if (tag == 'group' || tag == 'page' || tag == 'separator') {
      final label = element.getAttribute('string')?.trim();
      final groupTitle = (label != null && label.isNotEmpty)
          ? label
          : (currentGroup ?? OdooFieldExclusions.defaultGroupTitle);

      for (final child in element.children.whereType<XmlElement>()) {
        _visitElement(
          child,
          currentGroup: groupTitle,
          groupOrder: groupOrder,
          groupFieldsMap: groupFieldsMap,
          archFields: archFields,
          assignedFields: assignedFields,
        );
      }
      return;
    }

    if (tag == 'field') {
      final name = element.getAttribute('name');
      if (name == null || _isHiddenField(element)) return;

      archFields.add(name);

      final groupTitle = currentGroup ?? OdooFieldExclusions.defaultGroupTitle;
      if (!assignedFields.contains(name)) {
        _addFieldToGroup(
          name,
          groupTitle,
          groupOrder,
          groupFieldsMap,
          assignedFields,
        );
      }
      return;
    }

    for (final child in element.children.whereType<XmlElement>()) {
      _visitElement(
        child,
        currentGroup: currentGroup,
        groupOrder: groupOrder,
        groupFieldsMap: groupFieldsMap,
        archFields: archFields,
        assignedFields: assignedFields,
      );
    }
  }

  void _ensureGroup(
    String title,
    List<String> groupOrder,
    Map<String, List<String>> groupFieldsMap,
  ) {
    if (!groupFieldsMap.containsKey(title)) {
      groupFieldsMap[title] = [];
      groupOrder.add(title);
    }
  }

  void _addFieldToGroup(
    String name,
    String groupTitle,
    List<String> groupOrder,
    Map<String, List<String>> groupFieldsMap,
    Set<String> assignedFields,
  ) {
    _ensureGroup(groupTitle, groupOrder, groupFieldsMap);
    final list = groupFieldsMap[groupTitle]!;
    if (!list.contains(name)) {
      list.add(name);
    }
    assignedFields.add(name);
  }

  /// Any [invisible] / [column_invisible] attribute means hidden on mobile.
  bool _isHiddenField(XmlElement field) {
    final invisible = field.getAttribute('invisible');
    final columnInvisible = field.getAttribute('column_invisible');
    if (invisible != null && invisible.isNotEmpty) return true;
    if (columnInvisible != null && columnInvisible.isNotEmpty) return true;
    return false;
  }
}
