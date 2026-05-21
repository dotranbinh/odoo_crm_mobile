import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../odoo/odoo_field_definition.dart';
import '../odoo/odoo_field_formatter.dart';
import '../odoo/odoo_field_group.dart';
import 'odoo_field_tile.dart';
import 'section_header.dart';

class OdooDetailSection extends StatelessWidget {
  const OdooDetailSection({
    required this.group,
    required this.fieldDefinitions,
    required this.values,
    super.key,
    this.showEmptyFields = false,
  });

  final OdooFieldGroup group;
  final Map<String, OdooFieldDefinition> fieldDefinitions;
  final Map<String, dynamic> values;
  final bool showEmptyFields;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final name in group.fieldNames) {
      final def = fieldDefinitions[name];
      if (def == null) continue;

      if (!showEmptyFields && !def.showIfEmpty) {
        final display = OdooFieldFormatter.format(
          definition: def,
          value: values[name],
        );
        if (display == null || display.isEmpty) {
          if (kDebugMode && !_isEffectivelyEmpty(values[name])) {
            debugPrint(
              '[MobileUI] skip display field=$name group="${group.title}" '
              'raw=${values[name]} (formatter returned empty)',
            );
          }
          continue;
        }
      }

      children.add(OdooFieldTile(
        definition: def,
        value: values[name],
        showEmpty: showEmptyFields,
      ));
    }

    if (children.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[MobileUI] hide section "${group.title}" — no visible fields '
          '(configured: ${group.fieldNames.join(", ")})',
        );
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  AppSizes.sm,
                ),
                child: SectionHeader(title: group.title),
              ),
              const Divider(height: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  static bool _isEffectivelyEmpty(dynamic value) {
    if (value == null) return true;
    if (value is bool && !value) return true;
    if (value is String && value.trim().isEmpty) return true;
    return false;
  }
}
