import 'activity.dart';

/// Aggregated CRM metrics for the home screen.
class DashboardData {
  const DashboardData({
    required this.pipelineValue,
    required this.newCount,
    required this.qualifiedCount,
    required this.wonCount,
    required this.totalLeads,
    required this.newLeadsCount,
    required this.ordersCount,
    required this.activities,
  });

  final double pipelineValue;
  final int newCount;
  final int qualifiedCount;
  final int wonCount;
  final int totalLeads;
  final int newLeadsCount;
  final int ordersCount;
  final List<Activity> activities;

  int get pipelineLeadCount => newCount + qualifiedCount + wonCount;
}
