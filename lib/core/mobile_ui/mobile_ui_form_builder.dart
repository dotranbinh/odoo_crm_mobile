import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import 'mobile_ui_schema.dart';

typedef MobileFormValues = Map<String, dynamic>;

class MobileUiFormBuilder extends StatelessWidget {
  const MobileUiFormBuilder({
    required this.layout,
    required this.initialValues,
    required this.controllers,
    required this.onChanged,
    this.stageOptions = const [],
    super.key,
  });

  final MobileUiLayoutSchema layout;
  final Map<String, dynamic> initialValues;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;
  final List<({int id, String name})> stageOptions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (final section in layout.sections) {
      final fields = section.fields.where((f) => !f.readonly).toList();
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
        children.add(_buildField(context, field));
        children.add(const SizedBox(height: AppSizes.md));
      }
      children.add(const SizedBox(height: AppSizes.sm));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildField(BuildContext context, MobileUiFieldSchema field) {
    switch (field.widget) {
      case 'boolean':
        return CheckboxListTile(
          title: Text(field.label),
          value: initialValues[field.name] == true,
          onChanged: (v) {
            initialValues[field.name] = v ?? false;
            onChanged();
          },
          contentPadding: EdgeInsets.zero,
        );
      case 'date':
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: Text(
            _formatDate(initialValues[field.name]) ?? 'Select date',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _pickDate(context, field.name),
          ),
        );
      case 'stage':
        final stageId = _many2oneId(initialValues[field.name]);
        return DropdownButtonFormField<int>(
          initialValue: stageId,
          decoration: InputDecoration(labelText: field.label),
          items: [
            for (final s in stageOptions)
              DropdownMenuItem(value: s.id, child: Text(s.name)),
          ],
          onChanged: (v) {
            initialValues[field.name] = v;
            onChanged();
          },
        );
      case 'selection':
        final options = field.selection;
        if (options.isEmpty) {
          return _textField(context, field);
        }
        final current = initialValues[field.name]?.toString();
        return DropdownButtonFormField<String>(
          initialValue: options.any((o) => o.first.toString() == current)
              ? current
              : options.first.first.toString(),
          decoration: InputDecoration(labelText: field.label),
          items: [
            for (final opt in options)
              DropdownMenuItem(
                value: opt.first.toString(),
                child: Text(opt.length > 1 ? opt[1].toString() : opt.first.toString()),
              ),
          ],
          onChanged: (v) {
            initialValues[field.name] = v;
            onChanged();
          },
        );
      case 'priority':
        return DropdownButtonFormField<String>(
          initialValue: _strValue(initialValues[field.name]) ?? '1',
          decoration: InputDecoration(labelText: field.label),
          items: const [
            DropdownMenuItem(value: '0', child: Text('Low')),
            DropdownMenuItem(value: '1', child: Text('Normal')),
            DropdownMenuItem(value: '2', child: Text('High')),
            DropdownMenuItem(value: '3', child: Text('Very High')),
          ],
          onChanged: (v) {
            initialValues[field.name] = v;
            onChanged();
          },
        );
      case 'html':
      case 'text':
      case 'phone':
      case 'email':
      case 'url':
      case 'number':
      case 'currency':
      default:
        return _textField(context, field);
    }
  }

  Widget _textField(BuildContext context, MobileUiFieldSchema field) {
    final controller = controllers.putIfAbsent(
      field.name,
      () => TextEditingController(text: _strValue(initialValues[field.name]) ?? ''),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: field.label),
      keyboardType: _keyboardFor(field),
      maxLines: field.widget == 'html' ? 4 : 1,
      validator: field.required
          ? (v) => Validators.required(v, field: field.label)
          : field.widget == 'email'
              ? Validators.email
              : null,
      onChanged: (v) {
        initialValues[field.name] = v;
        onChanged();
      },
    );
  }

  int? _many2oneId(dynamic value) {
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value.first as int?;
    return int.tryParse(value?.toString() ?? '');
  }

  TextInputType _keyboardFor(MobileUiFieldSchema field) {
    return switch (field.widget) {
      'phone' => TextInputType.phone,
      'email' => TextInputType.emailAddress,
      'url' => TextInputType.url,
      'number' || 'currency' => const TextInputType.numberWithOptions(decimal: true),
      _ => TextInputType.text,
    };
  }

  Future<void> _pickDate(BuildContext context, String fieldName) async {
    final current = initialValues[fieldName];
    DateTime initial = DateTime.now();
    if (current is String && current.isNotEmpty) {
      initial = DateTime.tryParse(current) ?? initial;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      initialValues[fieldName] = picked.toIso8601String().split('T').first;
      onChanged();
    }
  }

  String? _strValue(dynamic value) {
    if (value == null || value is bool && !value) return null;
    return value.toString();
  }

  String? _formatDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
