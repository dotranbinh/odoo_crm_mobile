// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lead _$LeadFromJson(Map<String, dynamic> json) => _Lead(
  id: (json['id'] as num).toInt(),
  customerName: json['customerName'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  salesperson: json['salesperson'] as String,
  stage: $enumDecode(_$LeadStageEnumMap, json['stage']),
  source: json['source'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  title: json['title'] as String?,
  note: json['note'] as String?,
  companyName: json['companyName'] as String?,
  street: json['street'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  website: json['website'] as String?,
  mobile: json['mobile'] as String?,
  jobPosition: json['jobPosition'] as String?,
  expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble(),
  probability: (json['probability'] as num?)?.toDouble(),
  priority:
      $enumDecodeNullable(_$LeadPriorityEnumMap, json['priority']) ??
      LeadPriority.normal,
  dateDeadline: json['dateDeadline'] == null
      ? null
      : DateTime.parse(json['dateDeadline'] as String),
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$LeadToJson(_Lead instance) => <String, dynamic>{
  'id': instance.id,
  'customerName': instance.customerName,
  'phone': instance.phone,
  'email': instance.email,
  'salesperson': instance.salesperson,
  'stage': _$LeadStageEnumMap[instance.stage]!,
  'source': instance.source,
  'createdAt': instance.createdAt.toIso8601String(),
  'title': instance.title,
  'note': instance.note,
  'companyName': instance.companyName,
  'street': instance.street,
  'city': instance.city,
  'country': instance.country,
  'website': instance.website,
  'mobile': instance.mobile,
  'jobPosition': instance.jobPosition,
  'expectedRevenue': instance.expectedRevenue,
  'probability': instance.probability,
  'priority': _$LeadPriorityEnumMap[instance.priority]!,
  'dateDeadline': instance.dateDeadline?.toIso8601String(),
  'lastUpdated': instance.lastUpdated?.toIso8601String(),
  'tags': instance.tags,
};

const _$LeadStageEnumMap = {
  LeadStage.newLead: 'new',
  LeadStage.qualified: 'qualified',
  LeadStage.proposition: 'proposition',
  LeadStage.won: 'won',
  LeadStage.lost: 'lost',
};

const _$LeadPriorityEnumMap = {
  LeadPriority.low: 0,
  LeadPriority.normal: 1,
  LeadPriority.high: 2,
  LeadPriority.veryHigh: 3,
};
