// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduledActivity _$ScheduledActivityFromJson(Map<String, dynamic> json) =>
    _ScheduledActivity(
      id: (json['id'] as num).toInt(),
      summary: json['summary'] as String,
      activityTypeName: json['activityTypeName'] as String,
      activityTypeId: (json['activityTypeId'] as num).toInt(),
      dateDeadline: DateTime.parse(json['dateDeadline'] as String),
      assigneeName: json['assigneeName'] as String,
      assigneeId: (json['assigneeId'] as num?)?.toInt(),
      state:
          $enumDecodeNullable(_$ScheduledActivityStateEnumMap, json['state']) ??
          ScheduledActivityState.planned,
      isOverdue: json['isOverdue'] as bool? ?? false,
    );

Map<String, dynamic> _$ScheduledActivityToJson(_ScheduledActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'activityTypeName': instance.activityTypeName,
      'activityTypeId': instance.activityTypeId,
      'dateDeadline': instance.dateDeadline.toIso8601String(),
      'assigneeName': instance.assigneeName,
      'assigneeId': instance.assigneeId,
      'state': _$ScheduledActivityStateEnumMap[instance.state]!,
      'isOverdue': instance.isOverdue,
    };

const _$ScheduledActivityStateEnumMap = {
  ScheduledActivityState.overdue: 'overdue',
  ScheduledActivityState.today: 'today',
  ScheduledActivityState.planned: 'planned',
  ScheduledActivityState.done: 'done',
};
