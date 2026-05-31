import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/odoo/odoo_field_formatter.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

enum LeadStage {
  @JsonValue('new')
  newLead,
  @JsonValue('qualified')
  qualified,
  @JsonValue('proposition')
  proposition,
  @JsonValue('won')
  won,
  @JsonValue('lost')
  lost,
}

enum LeadPriority {
  @JsonValue(0)
  low,
  @JsonValue(1)
  normal,
  @JsonValue(2)
  high,
  @JsonValue(3)
  veryHigh,
}

@freezed
abstract class Lead with _$Lead {
  const factory Lead({
    required int id,
    required String customerName,
    required String phone,
    required String email,
    required String salesperson,
    required LeadStage stage,
    required String source,
    required DateTime createdAt,
    String? title,
    String? note,
    String? companyName,
    String? street,
    String? city,
    String? country,
    String? website,
    String? mobile,
    String? jobPosition,
    double? expectedRevenue,
    double? probability,
    @Default(LeadPriority.normal) LeadPriority priority,
    DateTime? dateDeadline,
    DateTime? lastUpdated,
    @Default(<String>[]) List<String> tags,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

  factory Lead.fromOdoo(Map<String, dynamic> json) => Lead(
        id: json['id'] as int? ?? 0,
        title: _strOrNull(json['name']),
        customerName: _str(json['partner_name']).isNotEmpty
            ? _str(json['partner_name'])
            : _str(json['contact_name']).isNotEmpty
                ? _str(json['contact_name'])
                : _str(json['name']),
        phone: _str(json['phone']),
        email: _str(json['email_from']),
        salesperson: _many2oneName(json['user_id']) ?? '',
        stage: _mapStage(_many2oneName(json['stage_id'])),
        source: _many2oneName(json['source_id']) ?? '',
        createdAt: json['create_date'] != null
            ? DateTime.tryParse(_str(json['create_date'])) ?? DateTime.now()
            : DateTime.now(),
        note: _plainNote(json['description']),
        companyName: _strOrNull(json['partner_name']) ??
            _many2oneName(json['partner_id']),
        street: _strOrNull(json['street']),
        city: _strOrNull(json['city']),
        country: _many2oneName(json['country_id']),
        website: _strOrNull(json['website']),
        mobile: _strOrNull(json['mobile']),
        jobPosition: _strOrNull(json['function']),
        expectedRevenue: _numOrNull(json['expected_revenue']),
        probability: _numOrNull(json['probability']),
        priority: _mapPriority(json['priority']),
        dateDeadline: _date(json['date_deadline']),
        lastUpdated: _date(json['write_date']),
        tags: _tagNames(json['tag_ids']),
      );
}

String _str(dynamic value) {
  if (value is String) return value;
  if (value is bool && !value) return '';
  return value?.toString() ?? '';
}

String? _strOrNull(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  if (value is bool && !value) return null;
  return null;
}

String? _plainNote(dynamic value) {
  final raw = _strOrNull(value);
  if (raw == null) return null;
  final plain = OdooFieldFormatter.stripHtml(raw);
  return plain.isEmpty ? null : plain;
}

double? _numOrNull(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? _date(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

LeadStage _mapStage(String? stageName) {
  final lower = (stageName ?? '').toLowerCase();
  if (lower.contains('won')) return LeadStage.won;
  if (lower.contains('lost')) return LeadStage.lost;
  if (lower.contains('qualif')) return LeadStage.qualified;
  if (lower.contains('propos')) return LeadStage.proposition;
  return LeadStage.newLead;
}

LeadPriority _mapPriority(dynamic raw) {
  final v = (raw is String) ? int.tryParse(raw) : (raw is num ? raw.toInt() : 0);
  switch (v) {
    case 3:
      return LeadPriority.veryHigh;
    case 2:
      return LeadPriority.high;
    case 1:
      return LeadPriority.normal;
    default:
      return LeadPriority.low;
  }
}

String? _many2oneName(dynamic value) {
  if (value is List && value.length > 1) return value[1]?.toString();
  if (value is bool && !value) return null;
  return value?.toString();
}

List<String> _tagNames(dynamic value) {
  // Odoo returns tag_ids as list of IDs by default; only names if read with
  // tag_ids in display fields. Keep as fallback.
  if (value is List) {
    return value
        .whereType<List>()
        .where((e) => e.length > 1)
        .map((e) => e[1].toString())
        .toList();
  }
  return const [];
}
