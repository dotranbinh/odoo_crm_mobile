import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import 'mobile_ui_field_renderer.dart';
import 'mobile_ui_form_context.dart';
import 'mobile_ui_schema.dart';

typedef MobileFormValues = Map<String, dynamic>;

class MobileUiFormBuilder extends StatelessWidget {
  const MobileUiFormBuilder({
    required this.layout,
    required this.initialValues,
    required this.controllers,
    required this.formContext,
    required this.onChanged,
    super.key,
  });

  final MobileUiLayoutSchema layout;
  final Map<String, dynamic> initialValues;
  final Map<String, TextEditingController> controllers;
  final MobileUiFormContext formContext;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final renderer = MobileUiFieldRenderer(
      context: context,
      formContext: formContext,
      initialValues: initialValues,
      controllers: controllers,
      onChanged: onChanged,
    );

    final children = <Widget>[];

    for (final section in layout.sections) {
      final fields = section.fields.where((field) => !field.readonly).toList();
      if (fields.isEmpty) continue;

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );

      for (final field in fields) {
        children.add(renderer.build(field));
        children.add(const SizedBox(height: AppSizes.md));
      }
      children.add(const SizedBox(height: AppSizes.sm));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
