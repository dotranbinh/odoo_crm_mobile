import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../odoo/odoo_many2many_enricher.dart';
import 'searchable_many2one_field.dart';

/// Multi-select tags for Odoo many2many fields (e.g. `tag_ids` on `crm.lead`).
class TagsField extends StatelessWidget {
  const TagsField({
    required this.label,
    required this.options,
    required this.selectedIds,
    required this.onChanged,
    super.key,
    this.readOnly = false,
  });

  final String label;
  final List<Many2oneOption> options;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final selected = Set<int>.from(selectedIds);

    if (readOnly) {
      final labels = options
          .where((o) => selected.contains(o.id))
          .map((o) => o.name)
          .toList();
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: labels.isEmpty
            ? const Text('—')
            : Wrap(
                spacing: AppSizes.xs,
                runSpacing: AppSizes.xs,
                children: [
                  for (final name in labels)
                    Chip(
                      label: Text(name),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSizes.sm),
        if (options.isEmpty)
          Text(
            'No tags available',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: AppSizes.xs,
            runSpacing: AppSizes.xs,
            children: [
              for (final option in options)
                FilterChip(
                  label: Text(option.name),
                  selected: selected.contains(option.id),
                  onSelected: (checked) {
                    final next = Set<int>.from(selected);
                    if (checked) {
                      next.add(option.id);
                    } else {
                      next.remove(option.id);
                    }
                    onChanged(next.toList()..sort());
                  },
                ),
            ],
          ),
      ],
    );
  }

  /// Build selected IDs from raw Odoo/form value.
  static List<int> idsFromValue(dynamic value) =>
      Many2manyValueHelper.parseIds(value);
}
