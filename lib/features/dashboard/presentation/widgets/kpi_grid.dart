import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../domain/kpi.dart';

class KpiGrid extends StatelessWidget {
  const KpiGrid({required this.kpis, super.key});

  final List<Kpi> kpis;

  IconData _iconFor(String name) {
    switch (name) {
      case 'people':
        return Icons.people;
      case 'person_add':
        return Icons.person_add;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.analytics;
    }
  }

  Color _colorFor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.primaryLight,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
        childAspectRatio: 1.05,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return SizedBox.expand(
          child: KpiCard(
            title: kpi.title,
            value: kpi.value,
            icon: _iconFor(kpi.iconName),
            color: _colorFor(index),
            trend: kpi.trend,
          ),
        );
      },
    );
  }
}
