class OdooFieldDefinition {
  const OdooFieldDefinition({
    required this.name,
    required this.type,
    required this.label,
    this.relation,
    this.widget,
    this.selection = const [],
    this.readonly = false,
    this.required = false,
    this.showIfEmpty = false,
  });

  final String name;
  final String type;
  final String label;
  final String? relation;
  final String? widget;
  final List<List<dynamic>> selection;
  final bool readonly;
  final bool required;
  final bool showIfEmpty;

  factory OdooFieldDefinition.fromJson(String name, Map<String, dynamic> json) {
    final rawSelection = json['selection'];
    final selection = <List<dynamic>>[];
    if (rawSelection is List) {
      for (final item in rawSelection) {
        if (item is List && item.length >= 2) {
          selection.add(item);
        }
      }
    }

    return OdooFieldDefinition(
      name: name,
      type: json['type']?.toString() ?? 'char',
      label: json['string']?.toString() ?? name,
      relation: json['relation']?.toString(),
      selection: selection,
      readonly: json['readonly'] == true,
      required: json['required'] == true,
    );
  }

  bool get isDisplayable => OdooFieldExclusions.isDisplayableType(type);

  bool get isCopyable =>
      type == 'char' &&
      (name.contains('phone') ||
          name.contains('email') ||
          name == 'mobile' ||
          name == 'website');
}

/// Fields/types omitted from mobile detail view.
abstract final class OdooFieldExclusions {
  static const defaultGroupTitle = 'General';

  static const excludedTypes = {
    'one2many',
    'many2many',
    'binary',
    'image',
    'reference',
    'properties',
  };

  static const excludedFieldNames = {
    'message_ids',
    'message_partner_ids',
    'message_follower_ids',
    'message_channel_ids',
    'activity_ids',
    'activity_state',
    'activity_user_id',
    'activity_type_id',
    'activity_summary',
    'activity_date_deadline',
    'activity_exception_decoration',
    'activity_exception_icon',
    'activity_calendar_event_id',
    'my_activity_date_deadline',
    'message_main_attachment_id',
    'message_has_error',
    'message_has_error_counter',
    'message_needaction',
    'message_needaction_counter',
    'message_attachment_count',
    'message_is_follower',
    'website_message_ids',
    'display_name',
    '__last_update',
    'access_token',
    'access_url',
    'access_warning',
  };

  static const _skipArchTags = {
    'header',
    'button',
    'label',
    'widget',
    'control',
    'create',
    'delete',
  };

  /// Studio / custom fields (Odoo convention).
  static bool isCustomField(String name) =>
      name.startsWith('x_') || name.startsWith('x_studio_');

  static bool isDisplayableType(String type) => !excludedTypes.contains(type);

  static bool isDisplayableField(String name, String type) {
    if (excludedFieldNames.contains(name)) return false;
    if (name.startsWith('message_') && name.endsWith('_ids')) return false;
    return isDisplayableType(type);
  }

  static bool shouldSkipArchElement(String localName) =>
      _skipArchTags.contains(localName);
}
