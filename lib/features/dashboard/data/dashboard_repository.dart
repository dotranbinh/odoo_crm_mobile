import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../../lead/domain/lead.dart';
import '../domain/activity.dart';
import '../domain/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._rpc);

  final OdooJsonRpcClient _rpc;

  Future<DashboardData> fetchDashboard() {
    if (AppConfig.useRealApi) {
      return _fetchRemote();
    }
    return _fetchMock();
  }

  Future<DashboardData> _fetchRemote() async {
    final results = await Future.wait([
      _readLeadStageGroups(),
      _searchCount('crm.lead', []),
      _searchCount('sale.order', []),
      _fetchRecentActivities(),
    ]);

    final groups = results[0] as List<_StageGroup>;
    final totalFromCount = results[1] as int;
    final ordersCount = results[2] as int;
    final activities = results[3] as List<Activity>;

    var pipelineValue = 0.0;
    var newCount = 0;
    var qualifiedCount = 0;
    var wonCount = 0;
    var newLeadsCount = 0;

    for (final group in groups) {
      final stage = _mapStageName(group.stageName);
      if (stage == LeadStage.lost) continue;

      pipelineValue += group.revenue;

      switch (stage) {
        case LeadStage.newLead:
          newCount += group.count;
          newLeadsCount += group.count;
        case LeadStage.qualified:
        case LeadStage.proposition:
          qualifiedCount += group.count;
        case LeadStage.won:
          wonCount += group.count;
        case LeadStage.lost:
          break;
      }
    }

    final totalLeads =
        totalFromCount > 0 ? totalFromCount : groups.fold(0, (s, g) => s + g.count);

    return DashboardData(
      pipelineValue: pipelineValue,
      newCount: newCount,
      qualifiedCount: qualifiedCount,
      wonCount: wonCount,
      totalLeads: totalLeads,
      newLeadsCount: newLeadsCount,
      ordersCount: ordersCount,
      activities: activities,
    );
  }

  Future<List<_StageGroup>> _readLeadStageGroups() async {
    final result = await _rpc.callKw(
      model: 'crm.lead',
      method: 'read_group',
      args: [],
      kwargs: {
        'domain': [
          ['type', '=', 'lead'],
        ],
        'fields': ['expected_revenue'],
        'groupby': ['stage_id'],
        'lazy': false,
      },
    );

    if (result is! List) return const [];

    return [
      for (final row in result)
        if (row is Map<String, dynamic>)
          _StageGroup(
            stageName: _many2oneName(row['stage_id']),
            count: _groupCount(row, 'stage_id'),
            revenue: _groupRevenue(row),
          ),
    ];
  }

  Future<int> _searchCount(String model, List<dynamic> domain) async {
    final result = await _rpc.callKw(
      model: model,
      method: 'search_count',
      args: [domain],
    );
    return result is int ? result : 0;
  }

  Future<List<Activity>> _fetchRecentActivities() async {
    final results = await Future.wait([
      _rpc.callKw(
        model: 'crm.lead',
        method: 'search_read',
        args: [
          [
            ['type', '=', 'lead'],
          ],
        ],
        kwargs: {
          'fields': ['name', 'partner_name', 'stage_id', 'write_date'],
          'order': 'write_date desc',
          'limit': 4,
        },
      ),
      _rpc.callKw(
        model: 'sale.order',
        method: 'search_read',
        args: [[]],
        kwargs: {
          'fields': ['name', 'partner_id', 'state', 'write_date'],
          'order': 'write_date desc',
          'limit': 4,
        },
      ),
    ]);

    final activities = <Activity>[];

    final leads = results[0];
    if (leads is List) {
      for (final row in leads) {
        if (row is! Map<String, dynamic>) continue;
        final id = row['id']?.toString() ?? '';
        final name = _leadDisplayName(row);
        final stage = _many2oneName(row['stage_id']) ?? '';
        final ts = _parseDate(row['write_date']) ?? DateTime.now();
        activities.add(
          Activity(
            id: 'lead-$id',
            title: name,
            subtitle: stage.isNotEmpty ? stage : 'Lead updated',
            timestamp: ts,
            type: 'lead',
          ),
        );
      }
    }

    final orders = results[1];
    if (orders is List) {
      for (final row in orders) {
        if (row is! Map<String, dynamic>) continue;
        final id = row['id']?.toString() ?? '';
        final number = row['name']?.toString() ?? 'Order';
        final customer = _many2oneName(row['partner_id']) ?? '';
        final state = row['state']?.toString() ?? '';
        final ts = _parseDate(row['write_date']) ?? DateTime.now();
        activities.add(
          Activity(
            id: 'order-$id',
            title: number,
            subtitle: customer.isNotEmpty ? customer : _orderStateLabel(state),
            timestamp: ts,
            type: 'order',
          ),
        );
      }
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(5).toList();
  }

  Future<DashboardData> _fetchMock() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return DashboardData(
      pipelineValue: 84200,
      newCount: 24,
      qualifiedCount: 18,
      wonCount: 12,
      totalLeads: 128,
      newLeadsCount: 24,
      ordersCount: 56,
      activities: [
        Activity(
          id: '1',
          title: 'Nguyen Van A',
          subtitle: 'New',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'lead',
        ),
        Activity(
          id: '2',
          title: 'SO-2024-089',
          subtitle: 'Tech Solutions Ltd',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: 'order',
        ),
        Activity(
          id: '3',
          title: 'Tran Thi B',
          subtitle: 'Qualified',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'lead',
        ),
      ],
    );
  }

  LeadStage _mapStageName(String? stageName) {
    final lower = (stageName ?? '').toLowerCase();
    if (lower.contains('won')) return LeadStage.won;
    if (lower.contains('lost')) return LeadStage.lost;
    if (lower.contains('qualif')) return LeadStage.qualified;
    if (lower.contains('propos')) return LeadStage.proposition;
    return LeadStage.newLead;
  }

  String _leadDisplayName(Map<String, dynamic> row) {
    final partner = row['partner_name']?.toString().trim() ?? '';
    if (partner.isNotEmpty) return partner;
    return row['name']?.toString().trim() ?? 'Lead';
  }

  String _orderStateLabel(String state) {
    switch (state) {
      case 'draft':
        return 'Draft';
      case 'sale':
        return 'Confirmed';
      case 'done':
        return 'Done';
      default:
        return state;
    }
  }

  int _groupCount(Map<String, dynamic> row, String groupField) {
    final countKey = '${groupField}_count';
    final raw = row[countKey] ?? row['__count'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }

  double _groupRevenue(Map<String, dynamic> row) {
    final raw = row['expected_revenue'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  String? _many2oneName(dynamic value) {
    if (value is List && value.length > 1) return value[1]?.toString();
    if (value is bool && !value) return null;
    return value?.toString();
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class _StageGroup {
  const _StageGroup({
    required this.stageName,
    required this.count,
    required this.revenue,
  });

  final String? stageName;
  final int count;
  final double revenue;
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(odooJsonRpcClientProvider));
});
