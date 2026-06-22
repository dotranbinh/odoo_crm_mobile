import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../domain/scheduled_activity.dart';

class LeadActivityRepository {
  LeadActivityRepository(this._rpc);

  final OdooJsonRpcClient _rpc;

  Future<List<ScheduledActivity>> fetchActivities(int leadId) async {
    if (!AppConfig.useRealApi) return _mockActivities(leadId);

    final rows = await _rpc.callKw(
      model: 'mail.activity',
      method: 'search_read',
      args: [
        [
          ['res_model', '=', 'crm.lead'],
          ['res_id', '=', leadId],
        ],
      ],
      kwargs: {
        'fields': [
          'id',
          'summary',
          'activity_type_id',
          'date_deadline',
          'user_id',
          'state',
        ],
        'order': 'date_deadline asc',
      },
    );

    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) ScheduledActivity.fromOdoo(row),
    ];
  }

  Future<List<({int id, String name})>> fetchActivityTypes() async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Call'),
        (id: 2, name: 'Meeting'),
        (id: 3, name: 'To-Do'),
        (id: 4, name: 'Email'),
      ];
    }

    final rows = await _rpc.callKw(
      model: 'mail.activity.type',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': ['id', 'name'],
        'order': 'name asc',
      },
    );

    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<void> scheduleActivity({
    required int leadId,
    required int activityTypeId,
    required String summary,
    required DateTime dateDeadline,
    int? userId,
  }) async {
    if (!AppConfig.useRealApi) return;

    await _rpc.callKw(
      model: 'crm.lead',
      method: 'activity_schedule',
      args: [
        [leadId],
      ],
      kwargs: {
        'activity_type_id': activityTypeId,
        'summary': summary,
        'date_deadline': _formatDate(dateDeadline),
        if (userId != null) 'user_id': userId,
      },
    );
  }

  Future<void> markActivityDone({
    required int activityId,
    String? feedback,
  }) async {
    if (!AppConfig.useRealApi) return;

    await _rpc.callKw(
      model: 'mail.activity',
      method: 'action_feedback',
      args: [
        [activityId],
      ],
      kwargs: {
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<ScheduledActivity> _mockActivities(int leadId) {
    final now = DateTime.now();
    return [
      ScheduledActivity(
        id: 1,
        summary: 'Follow-up call for lead #$leadId',
        activityTypeName: 'Call',
        activityTypeId: 1,
        dateDeadline: now.subtract(const Duration(days: 1)),
        assigneeName: 'Administrator',
        state: ScheduledActivityState.overdue,
        isOverdue: true,
      ),
      ScheduledActivity(
        id: 2,
        summary: 'Send proposal',
        activityTypeName: 'To-Do',
        activityTypeId: 3,
        dateDeadline: now.add(const Duration(days: 2)),
        assigneeName: 'Administrator',
        state: ScheduledActivityState.planned,
      ),
    ];
  }
}

final leadActivityRepositoryProvider = Provider<LeadActivityRepository>(
  (ref) => LeadActivityRepository(ref.watch(odooJsonRpcClientProvider)),
);
