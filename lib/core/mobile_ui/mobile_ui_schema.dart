/// Layout JSON from Odoo `mobile.ui.layout.get_mobile_layout`.
class MobileUiLayoutSchema {
  const MobileUiLayoutSchema({
    required this.version,
    required this.model,
    required this.screen,
    required this.sections,
    this.otherInfoTitle = 'Other Information',
    this.includeCustomFields = false,
  });

  final int version;
  final String model;
  final String screen;
  final String otherInfoTitle;
  final bool includeCustomFields;
  final List<MobileUiSectionSchema> sections;

  bool get isConfigured => version > 0 && sections.isNotEmpty;

  List<String> get fieldNames {
    final names = <String>{'id'};
    for (final s in sections) {
      for (final f in s.fields) {
        names.add(f.name);
      }
    }
    return names.toList();
  }

  MobileUiFieldSchema? fieldByName(String name) {
    for (final s in sections) {
      for (final f in s.fields) {
        if (f.name == name) return f;
      }
    }
    return null;
  }

  MobileUiFieldSchema? get listPrimaryField {
    for (final s in sections) {
      for (final f in s.fields) {
        if (f.listPrimary) return f;
      }
    }
    return sections.isNotEmpty && sections.first.fields.isNotEmpty
        ? sections.first.fields.first
        : null;
  }

  List<MobileUiFieldSchema> get listLineFields => [
        for (final s in sections)
          for (final f in s.fields)
            if (!f.listPrimary && !f.listSubtitle) f,
      ];

  MobileUiFieldSchema? get listSubtitleField {
    for (final s in sections) {
      for (final f in s.fields) {
        if (f.listSubtitle) return f;
      }
    }
    return null;
  }

  factory MobileUiLayoutSchema.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];
    final sections = <MobileUiSectionSchema>[];
    if (sectionsJson is List) {
      for (final item in sectionsJson) {
        if (item is Map) {
          sections.add(
            MobileUiSectionSchema.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    sections.sort((a, b) => a.sequence.compareTo(b.sequence));

    return MobileUiLayoutSchema(
      version: json['version'] as int? ?? 0,
      model: json['model']?.toString() ?? '',
      screen: json['screen']?.toString() ?? 'detail',
      otherInfoTitle:
          json['other_info_title']?.toString() ?? 'Other Information',
      includeCustomFields: json['include_custom_fields'] == true,
      sections: sections,
    );
  }
}

class MobileUiSectionSchema {
  const MobileUiSectionSchema({
    required this.key,
    required this.title,
    required this.sequence,
    required this.fields,
    this.collapsed = false,
  });

  final String key;
  final String title;
  final int sequence;
  final bool collapsed;
  final List<MobileUiFieldSchema> fields;

  factory MobileUiSectionSchema.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['fields'];
    final fields = <MobileUiFieldSchema>[];
    if (fieldsJson is List) {
      for (final item in fieldsJson) {
        if (item is Map) {
          fields.add(
            MobileUiFieldSchema.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    fields.sort((a, b) => a.sequence.compareTo(b.sequence));

    return MobileUiSectionSchema(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sequence: json['sequence'] as int? ?? 10,
      collapsed: json['collapsed'] == true,
      fields: fields,
    );
  }
}

class MobileUiFieldSchema {
  const MobileUiFieldSchema({
    required this.name,
    required this.label,
    required this.type,
    required this.widget,
    this.readonly = false,
    this.required = false,
    this.showIfEmpty = false,
    this.copyable = false,
    this.listPrimary = false,
    this.listSubtitle = false,
    this.selection = const [],
    this.relation,
    this.sequence = 10,
  });

  final String name;
  final String label;
  final String type;
  final String widget;
  final bool readonly;
  final bool required;
  final bool showIfEmpty;
  final bool copyable;
  final bool listPrimary;
  final bool listSubtitle;
  final List<List<dynamic>> selection;
  final String? relation;
  final int sequence;

  factory MobileUiFieldSchema.fromJson(Map<String, dynamic> json) {
    final rawSel = json['selection'];
    final selection = <List<dynamic>>[];
    if (rawSel is List) {
      for (final item in rawSel) {
        if (item is List && item.length >= 2) {
          selection.add(item);
        }
      }
    }

    final rawRelation = json['relation'];
    final relation = rawRelation == null ||
            rawRelation == false ||
            rawRelation.toString().isEmpty
        ? null
        : rawRelation.toString();

    return MobileUiFieldSchema(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'char',
      widget: json['widget']?.toString() ?? 'text',
      readonly: json['readonly'] == true,
      required: json['required'] == true,
      showIfEmpty: json['show_if_empty'] == true,
      copyable: json['copyable'] == true,
      listPrimary: json['list_primary'] == true,
      listSubtitle: json['list_subtitle'] == true,
      selection: selection,
      relation: relation,
      sequence: json['sequence'] as int? ?? 10,
    );
  }
}
