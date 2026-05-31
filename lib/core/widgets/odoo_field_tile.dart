import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../odoo/odoo_field_definition.dart';
import '../odoo/odoo_field_formatter.dart';
import '../odoo/odoo_many2many_enricher.dart';

class OdooFieldTile extends StatelessWidget {
  const OdooFieldTile({
    required this.definition,
    required this.value,
    super.key,
    this.showEmpty = false,
  });

  final OdooFieldDefinition definition;
  final dynamic value;
  final bool showEmpty;

  bool get _useTagChips =>
      definition.widget == 'tags' ||
      (definition.type == 'many2many' && definition.widget != 'text');

  @override
  Widget build(BuildContext context) {
    final tagLabels = _useTagChips ? Many2manyValueHelper.labels(value) : null;

    final display = tagLabels == null
        ? OdooFieldFormatter.format(
            definition: definition,
            value: value,
          )
        : (tagLabels.isEmpty ? null : tagLabels.join(', '));

    if (!showEmpty &&
        !definition.showIfEmpty &&
        (display == null || display.isEmpty) &&
        (tagLabels == null || tagLabels.isEmpty)) {
      return const SizedBox.shrink();
    }

    final text = display ?? '—';
    final canCopy = definition.isCopyable && text != '—' && tagLabels == null;

    return InkWell(
      onTap: canCopy
          ? () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${definition.label} copied'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForType(definition.type),
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  if (tagLabels != null && tagLabels.isNotEmpty)
                    Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: AppSizes.xs,
                      children: [
                        for (final label in tagLabels)
                          Chip(
                            label: Text(label),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    )
                  else
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            if (canCopy)
              const Padding(
                padding: EdgeInsets.only(left: AppSizes.sm),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
        'boolean' => Icons.toggle_on_outlined,
        'integer' || 'float' || 'monetary' => Icons.numbers_outlined,
        'date' || 'datetime' => Icons.calendar_today_outlined,
        'selection' => Icons.list_alt_outlined,
        'many2one' || 'many2many' => Icons.link_outlined,
        'html' || 'text' => Icons.notes_outlined,
        _ => Icons.info_outline,
      };
}
