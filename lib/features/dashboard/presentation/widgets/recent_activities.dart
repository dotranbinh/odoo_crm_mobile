import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/activity.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({required this.activities, super.key});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < activities.length; i++)
          _TimelineRow(
            activity: activities[i],
            isFirst: i == 0,
            isLast: i == activities.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.activity,
    required this.isFirst,
    required this.isLast,
  });

  final Activity activity;
  final bool isFirst;
  final bool isLast;

  Color get _accent => switch (activity.type) {
        'lead' => AppColors.primary,
        'order' => AppColors.statusWonText,
        'meeting' => AppColors.statusQualifiedText,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: AppSizes.borderWidth,
                      color: isFirst ? Colors.transparent : AppColors.border,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: AppSizes.borderWidth,
                      color: isLast ? Colors.transparent : AppColors.border,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : AppSizes.sm,
                bottom: isLast ? 0 : AppSizes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (activity.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.relative(activity.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
