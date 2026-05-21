import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import '../domain/kpi.dart';

class DashboardRepository {
  Future<DashboardData> fetchDashboard() => _fetchMock();

  Future<DashboardData> _fetchMock() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return DashboardData(
      kpis: [
        const Kpi(
          id: 'total_leads',
          title: 'Total Leads',
          value: '128',
          iconName: 'people',
          trend: '+12%',
        ),
        const Kpi(
          id: 'new_leads',
          title: 'New Leads',
          value: '24',
          iconName: 'person_add',
          trend: '+8%',
        ),
        const Kpi(
          id: 'orders',
          title: 'Orders',
          value: '56',
          iconName: 'shopping_cart',
          trend: '+5%',
        ),
        const Kpi(
          id: 'revenue',
          title: 'Monthly Revenue',
          value: '\$84.2K',
          iconName: 'attach_money',
          trend: '+18%',
        ),
      ],
      activities: [
        Activity(
          id: '1',
          title: 'New lead: Nguyen Van A',
          subtitle: 'Assigned to you',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'lead',
        ),
        Activity(
          id: '2',
          title: 'Order SO-2024-089 confirmed',
          subtitle: 'Customer: Tech Solutions Ltd',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: 'order',
        ),
        Activity(
          id: '3',
          title: 'Lead moved to Qualified',
          subtitle: 'Tran Thi B — Enterprise deal',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'lead',
        ),
        Activity(
          id: '4',
          title: 'Meeting scheduled',
          subtitle: 'Follow-up with Global Corp',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: 'meeting',
        ),
      ],
    );
  }
}

class DashboardData {
  const DashboardData({
    required this.kpis,
    required this.activities,
  });

  final List<Kpi> kpis;
  final List<Activity> activities;
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});
