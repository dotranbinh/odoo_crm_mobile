import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/activity.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({required this.activities, super.key});

  final List<Activity> activities;

  IconData _iconFor(String type) {
    switch (type) {
      case 'lead':
        return Icons.person_add;
      case 'order':
        return Icons.shopping_bag;
      case 'meeting':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'lead':
        return AppColors.primary;
      case 'order':
        return AppColors.success;
      case 'meeting':
        return AppColors.warning;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor:
                _colorFor(activity.type).withValues(alpha: 0.12),
            child: Icon(
              _iconFor(activity.type),
              color: _colorFor(activity.type),
              size: 20,
            ),
          ),
          title: Text(
            activity.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(activity.subtitle),
          trailing: Text(
            AppFormatters.relative(activity.timestamp),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      },
    );
  }
}
