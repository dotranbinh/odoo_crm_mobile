import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_sizes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/pipeline_hero_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activities.dart';
import 'widgets/stats_strip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: dashboardAsync.when(
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
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                AppSizes.sm,
                AppSizes.screenPaddingH,
                AppSizes.xxl,
              ),
              children: [
                DashboardHeader(userName: user?.name ?? 'User'),
                const SizedBox(height: AppSizes.md),
                PipelineHeroCard(data: data),
                const SizedBox(height: AppSizes.sm),
                StatsStrip(data: data),
                const SizedBox(height: AppSizes.md),
                const QuickActions(),
                const SizedBox(height: AppSizes.lg),
                SectionHeader(title: l10n.recentActivities),
                const SizedBox(height: AppSizes.sm),
                RecentActivities(activities: data.activities),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
