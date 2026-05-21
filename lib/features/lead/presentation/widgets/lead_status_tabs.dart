import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/lead.dart';

class LeadStatusTabs extends StatelessWidget {
  const LeadStatusTabs({
    required this.selected,
    required this.onSelected,
    required this.labels,
    super.key,
  });

  final LeadStage? selected;
  final ValueChanged<LeadStage?> onSelected;
  final Map<LeadStage?, String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: labels.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: StatusChip(
              label: entry.value,
              color: _colorFor(entry.key),
              selected: isSelected,
              onTap: () => onSelected(isSelected ? null : entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _colorFor(LeadStage? stage) {
    switch (stage) {
      case LeadStage.newLead:
        return const Color(0xFF714B67);
      case LeadStage.qualified:
        return const Color(0xFFFFC107);
      case LeadStage.proposition:
        return const Color(0xFF17A2B8);
      case LeadStage.won:
        return const Color(0xFF28A745);
      case LeadStage.lost:
        return const Color(0xFFDC3545);
      case null:
        return const Color(0xFF6B6B7B);
    }
  }
}
