import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_activity.freezed.dart';
part 'scheduled_activity.g.dart';

enum ScheduledActivityState {
  @JsonValue('overdue')
  overdue,
  @JsonValue('today')
  today,
  @JsonValue('planned')
  planned,
  @JsonValue('done')
  done,
}

@freezed
abstract class ScheduledActivity with _$ScheduledActivity {
  const factory ScheduledActivity({
    required int id,
    required String summary,
    required String activityTypeName,
    required int activityTypeId,
    required DateTime dateDeadline,
    required String assigneeName,
    int? assigneeId,
    @Default(ScheduledActivityState.planned) ScheduledActivityState state,
    @Default(false) bool isOverdue,
  }) = _ScheduledActivity;

  factory ScheduledActivity.fromJson(Map<String, dynamic> json) =>
      _$ScheduledActivityFromJson(json);

  factory ScheduledActivity.fromOdoo(Map<String, dynamic> json) {
    final deadline = json['date_deadline'];
    final date = deadline is String && deadline.isNotEmpty
        ? DateTime.tryParse(deadline) ?? DateTime.now()
        : DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(date.year, date.month, date.day);
    final isOverdue = deadlineDay.isBefore(today);
    final isToday = deadlineDay == today;

    ScheduledActivityState state;
    if (isOverdue) {
      state = ScheduledActivityState.overdue;
    } else if (isToday) {
      state = ScheduledActivityState.today;
    } else {
      state = ScheduledActivityState.planned;
    }

    return ScheduledActivity(
      id: json['id'] as int? ?? 0,
      summary: json['summary']?.toString() ?? '',
      activityTypeName: _many2oneName(json['activity_type_id']) ?? 'Activity',
      activityTypeId: _many2oneId(json['activity_type_id']) ?? 0,
      dateDeadline: date,
      assigneeName: _many2oneName(json['user_id']) ?? '',
      assigneeId: _many2oneId(json['user_id']),
      state: state,
      isOverdue: isOverdue,
    );
  }
}

int? _many2oneId(dynamic value) {
  if (value is List && value.isNotEmpty) return value.first as int?;
  return null;
}

String? _many2oneName(dynamic value) {
  if (value is List && value.length > 1) return value[1]?.toString();
  return null;
}
