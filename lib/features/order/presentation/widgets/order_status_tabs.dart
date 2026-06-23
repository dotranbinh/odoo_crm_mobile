import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/order.dart';

class OrderStatusTabs extends StatelessWidget {
  const OrderStatusTabs({
    required this.selected,
    required this.onSelected,
    required this.labels,
    super.key,
  });

  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onSelected;
  final Map<OrderStatus?, String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: labels.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.lg),
            child: _UnderlineTab(
              label: entry.value,
              selected: isSelected,
              onTap: () => onSelected(isSelected ? null : entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  const _UnderlineTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected
                      ? AppColors.primaryTintText
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 28,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
