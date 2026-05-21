import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activities.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : 'U')
                    .toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => LoadingView(message: l10n.loading),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              Text(
                l10n.greeting(user?.name ?? 'User'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSizes.lg),
              KpiGrid(kpis: data.kpis),
              const SizedBox(height: AppSizes.lg),
              SectionHeader(title: l10n.quickActions),
              const SizedBox(height: AppSizes.md),
              const QuickActions(),
              const SizedBox(height: AppSizes.lg),
              SectionHeader(title: l10n.recentActivities),
              const SizedBox(height: AppSizes.md),
              RecentActivities(activities: data.activities),
            ],
          ),
        ),
      ),
    );
  }
}
