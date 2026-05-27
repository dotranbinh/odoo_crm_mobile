import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../utils/validators.dart';
import '../widgets/searchable_many2one_field.dart';
import 'mobile_ui_form_context.dart';
import 'mobile_ui_schema.dart';

/// Renders a single mobile UI form field using Odoo [type] + optional [widget].
class MobileUiFieldRenderer {
  const MobileUiFieldRenderer({
    required this.context,
    required this.formContext,
    required this.initialValues,
    required this.controllers,
    required this.onChanged,
  });

  final BuildContext context;
  final MobileUiFormContext formContext;
  final Map<String, dynamic> initialValues;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  Widget build(MobileUiFieldSchema field) {
    final widgetOverride = _buildWidgetOverride(field);
    if (widgetOverride != null) return widgetOverride;

    switch (field.type) {
      case 'many2one':
        return _buildMany2one(field);
      case 'many2many':
        return _buildMany2manyReadOnly(field);
      case 'one2many':
        return _buildOne2manyReadOnly(field);
      case 'boolean':
        return _buildBoolean(field);
      case 'date':
      case 'datetime':
        return _buildDate(field);
      case 'selection':
        return _buildSelection(field);
      case 'integer':
      case 'float':
      case 'monetary':
        return _buildNumber(field);
      default:
        return _buildText(field);
    }
  }

  Widget? _buildWidgetOverride(MobileUiFieldSchema field) {
    return switch (field.widget) {
      'stage' => _buildStaticMany2oneDropdown(field),
      'priority' => _buildPriority(field),
      'phone' || 'email' || 'url' || 'html' => _buildText(field),
      _ => null,
    };
  }

  Widget _buildMany2one(MobileUiFieldSchema field) {
    final staticOptions = formContext.staticMany2oneOptions[field.name];
    if (staticOptions != null && staticOptions.isNotEmpty) {
      return _buildStaticMany2oneDropdown(field, options: staticOptions);
    }

    final relation = field.relation;
    if (relation != null && relation.isNotEmpty) {
      return _buildSearchableMany2one(field);
    }

    return _buildRelationReadOnly(field);
  }

  Widget _buildStaticMany2oneDropdown(
    MobileUiFieldSchema field, {
    List<Many2oneOption>? options,
  }) {
    final items = options ?? formContext.staticMany2oneOptions[field.name] ?? [];
    final selectedId =
        SearchableMany2oneField.idFromValue(initialValues[field.name]);
    final validId =
        selectedId != null && items.any((item) => item.id == selectedId)
            ? selectedId
            : null;

    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: validId,
      decoration: InputDecoration(labelText: field.label),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item.id,
            child: _dropdownLabel(item.name),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        final match = items.firstWhere((item) => item.id == value);
        initialValues[field.name] = [match.id, match.name];
        onChanged();
      },
    );
  }

  Widget _buildSearchableMany2one(MobileUiFieldSchema field) {
    final valueId =
        SearchableMany2oneField.idFromValue(initialValues[field.name]);
    final displayText =
        SearchableMany2oneField.displayNameFromValue(initialValues[field.name]);

    return SearchableMany2oneField(
      label: field.label,
      valueId: valueId,
      displayText: displayText,
      searchHint: 'Search ${field.label.toLowerCase()}…',
      onSearch: (query) => formContext.searchMany2one(field, query),
      onSelected: (option) {
        initialValues[field.name] =
            option == null ? false : [option.id, option.name];
        onChanged();
      },
      validator: field.required
          ? (value) =>
              value == null ? Validators.required('', field: field.label) : null
          : null,
    );
  }

  Widget _buildRelationReadOnly(MobileUiFieldSchema field) {
    final label = SearchableMany2oneField.displayNameFromValue(
          initialValues[field.name],
        ) ??
        _strValue(initialValues[field.name]) ??
        '—';

    return InputDecorator(
      decoration: InputDecoration(labelText: field.label),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildMany2manyReadOnly(MobileUiFieldSchema field) {
    final labels = _relationLabels(initialValues[field.name]);
    return InputDecorator(
      decoration: InputDecoration(labelText: field.label),
      child: labels.isEmpty
          ? const Text('—')
          : Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              children: labels.map((label) => Chip(label: Text(label))).toList(),
            ),
    );
  }

  Widget _buildOne2manyReadOnly(MobileUiFieldSchema field) {
    final labels = _relationLabels(initialValues[field.name]);
    return InputDecorator(
      decoration: InputDecoration(labelText: field.label),
      child: Text(
        labels.isEmpty ? '—' : '${labels.length} record(s)',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildBoolean(MobileUiFieldSchema field) {
    return CheckboxListTile(
      title: Text(field.label),
      value: initialValues[field.name] == true,
      onChanged: (value) {
        initialValues[field.name] = value ?? false;
        onChanged();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDate(MobileUiFieldSchema field) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(field.label),
      subtitle: Text(_formatDate(initialValues[field.name]) ?? 'Select date'),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today_outlined),
        onPressed: () => _pickDate(field.name),
      ),
    );
  }

  Widget _buildSelection(MobileUiFieldSchema field) {
    final options = field.selection;
    if (options.isEmpty) {
      return _buildText(field);
    }

    final current = initialValues[field.name]?.toString();
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: options.any((option) => option.first.toString() == current)
          ? current
          : options.first.first.toString(),
      decoration: InputDecoration(labelText: field.label),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option.first.toString(),
            child: _dropdownLabel(
              option.length > 1
                  ? option[1].toString()
                  : option.first.toString(),
            ),
          ),
      ],
      onChanged: (value) {
        initialValues[field.name] = value;
        onChanged();
      },
    );
  }

  Widget _buildPriority(MobileUiFieldSchema field) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _strValue(initialValues[field.name]) ?? '1',
      decoration: InputDecoration(labelText: field.label),
      items: const [
        DropdownMenuItem(value: '0', child: Text('Low')),
        DropdownMenuItem(value: '1', child: Text('Normal')),
        DropdownMenuItem(value: '2', child: Text('High')),
        DropdownMenuItem(value: '3', child: Text('Very High')),
      ],
      onChanged: (value) {
        initialValues[field.name] = value;
        onChanged();
      },
    );
  }

  Widget _buildNumber(MobileUiFieldSchema field) {
    return _buildText(
      field,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildText(
    MobileUiFieldSchema field, {
    TextInputType? keyboardType,
  }) {
    final controller = controllers.putIfAbsent(
      field.name,
      () => TextEditingController(
        text: _strValue(initialValues[field.name]) ?? '',
      ),
    );

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: field.label),
      keyboardType: keyboardType ?? _keyboardFor(field),
      maxLines: field.widget == 'html' ? 4 : 1,
      validator: field.required
          ? (value) => Validators.required(value, field: field.label)
          : field.widget == 'email'
              ? Validators.email
              : null,
      onChanged: (value) {
        initialValues[field.name] = value;
        onChanged();
      },
    );
  }

  List<String> _relationLabels(dynamic value) {
    if (value is! List) return const [];
    final labels = <String>[];
    for (final item in value) {
      if (item is List && item.length > 1) {
        labels.add(item[1].toString());
      } else if (item is Map && item['display_name'] != null) {
        labels.add(item['display_name'].toString());
      } else if (item is String && item.isNotEmpty) {
        labels.add(item);
      }
    }
    return labels;
  }

  Future<void> _pickDate(String fieldName) async {
    final current = initialValues[fieldName];
    var initial = DateTime.now();
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

  TextInputType _keyboardFor(MobileUiFieldSchema field) {
    return switch (field.widget) {
      'phone' => TextInputType.phone,
      'email' => TextInputType.emailAddress,
      'url' => TextInputType.url,
      _ => TextInputType.text,
    };
  }

  static Widget _dropdownLabel(String text) => Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );

  String? _strValue(dynamic value) {
    if (value == null || value is bool && !value) return null;
    return value.toString();
  }

  String? _formatDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }
}
