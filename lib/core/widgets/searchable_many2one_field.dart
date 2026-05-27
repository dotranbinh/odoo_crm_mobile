import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import 'search_field.dart';

typedef Many2oneOption = ({int id, String name});

/// Sentinel returned when the user clears the selection (not dismiss).
const clearMany2oneSelection = Object();

/// Many2one picker with search (bottom sheet). Supports async Odoo lookup.
class SearchableMany2oneField extends StatelessWidget {
  const SearchableMany2oneField({
    required this.label,
    required this.onSearch,
    required this.onSelected,
    this.valueId,
    this.displayText,
    this.searchHint = 'Search…',
    this.validator,
    super.key,
  });

  final String label;
  final int? valueId;
  final String? displayText;
  final String searchHint;
  final Future<List<Many2oneOption>> Function(String query) onSearch;
  final ValueChanged<Many2oneOption?> onSelected;
  final String? Function(Many2oneOption? value)? validator;

  static String? displayNameFromValue(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString();
    }
    return null;
  }

  static int? idFromValue(dynamic value) {
    if (value is int) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is int) return first;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  Many2oneOption? get _currentValue => valueId == null
      ? null
      : (id: valueId!, name: displayText ?? '#$valueId');

  Future<void> _openPicker(BuildContext context, FormFieldState<Many2oneOption?> field) async {
    final picked = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _SearchableMany2oneSheet(
        title: label,
        searchHint: searchHint,
        onSearch: onSearch,
        initialSelection: _currentValue,
      ),
    );
    if (!context.mounted || picked == null) return;
    if (picked == clearMany2oneSelection) {
      onSelected(null);
      field.didChange(null);
      return;
    }
    if (picked is Many2oneOption) {
      onSelected(picked);
      field.didChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = displayText?.trim().isNotEmpty == true
        ? displayText!
        : (valueId != null ? '#$valueId' : null);

    return FormField<Many2oneOption?>(
      key: ValueKey('many2one-$valueId-$displayText'),
      initialValue: _currentValue,
      validator: validator,
      builder: (field) {
        return InkWell(
          onTap: () => _openPicker(context, field),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              shown ?? '—',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: shown == null
                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      )
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}

class _SearchableMany2oneSheet extends StatefulWidget {
  const _SearchableMany2oneSheet({
    required this.title,
    required this.searchHint,
    required this.onSearch,
    this.initialSelection,
  });

  final String title;
  final String searchHint;
  final Future<List<Many2oneOption>> Function(String query) onSearch;
  final Many2oneOption? initialSelection;

  @override
  State<_SearchableMany2oneSheet> createState() =>
      _SearchableMany2oneSheetState();
}

class _SearchableMany2oneSheetState extends State<_SearchableMany2oneSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Many2oneOption> _results = [];
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.onSearch(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SearchField(
                controller: _searchController,
                hint: widget.searchHint,
                onChanged: _onQueryChanged,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            ListTile(
              dense: true,
              title: const Text('—'),
              onTap: () => Navigator.pop(context, clearMany2oneSelection),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(_error.toString()),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          'No results',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final selected = widget.initialSelection?.id == item.id;
        return ListTile(
          title: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          trailing: selected ? const Icon(Icons.check, size: 20) : null,
          onTap: () => Navigator.pop(context, item),
        );
      },
    );
  }
}
