import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/order_line.dart';

class OrderLinesEditor extends StatefulWidget {
  const OrderLinesEditor({
    required this.lines,
    required this.onChanged,
    required this.onSearchProducts,
    required this.onFetchPrice,
    super.key,
  });

  final List<OrderLine> lines;
  final ValueChanged<List<OrderLine>> onChanged;
  final Future<List<({int id, String name})>> Function(String query)
      onSearchProducts;
  final Future<double?> Function(int productId) onFetchPrice;

  @override
  State<OrderLinesEditor> createState() => _OrderLinesEditorState();
}

class _OrderLinesEditorState extends State<OrderLinesEditor> {
  Future<void> _addLine() async {
    final product = await _ProductSearchSheet.show(
      context,
      onSearch: widget.onSearchProducts,
    );
    if (product == null || !mounted) return;

    final price = await widget.onFetchPrice(product.id) ?? 0;
    final line = OrderLine.draft(
      productId: product.id,
      productName: product.name,
      priceUnit: price,
    );
    widget.onChanged([...widget.lines, line]);
  }

  void _removeLine(int index) {
    final updated = [...widget.lines]..removeAt(index);
    widget.onChanged(updated);
  }

  void _updateLine(int index, OrderLine line) {
    final updated = [...widget.lines];
    updated[index] = line;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.orderLines,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addLine),
            ),
          ],
        ),
        if (widget.lines.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.atLeastOneLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (var i = 0; i < widget.lines.length; i++)
            _LineCard(
              line: widget.lines[i],
              onRemove: () => _removeLine(i),
              onChanged: (line) => _updateLine(i, line),
            ),
      ],
    );
  }
}

class _LineCard extends StatefulWidget {
  const _LineCard({
    required this.line,
    required this.onRemove,
    required this.onChanged,
  });

  final OrderLine line;
  final VoidCallback onRemove;
  final ValueChanged<OrderLine> onChanged;

  @override
  State<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends State<_LineCard> {
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.line.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.line.priceUnit.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line.productId != widget.line.productId) {
      _qtyController.text = widget.line.quantity.toString();
      _priceController.text = widget.line.priceUnit.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _emit() {
    final qty = double.tryParse(_qtyController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0;
    widget.onChanged(
      widget.line.copyWith(
        quantity: qty,
        priceUnit: price,
        subtotal: qty * price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtotal = widget.line.quantity * widget.line.priceUnit;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.line.productName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.danger,
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: l10n.unitPrice,
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${l10n.subtotal}: \$${subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchSheet extends StatefulWidget {
  const _ProductSearchSheet({required this.onSearch});

  final Future<List<({int id, String name})>> Function(String query) onSearch;

  static Future<({int id, String name})?> show(
    BuildContext context, {
    required Future<List<({int id, String name})>> Function(String query)
        onSearch,
  }) =>
      showModalBottomSheet<({int id, String name})>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ProductSearchSheet(onSearch: onSearch),
      );

  @override
  State<_ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<_ProductSearchSheet> {
  final _controller = TextEditingController();
  List<({int id, String name})> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final results = await widget.onSearch(query);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          AppSizes.md,
          AppSizes.screenPaddingH,
          MediaQuery.viewInsetsOf(context).bottom + AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.product,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: AppSizes.sm),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final product = _results[index];
                    return ListTile(
                      title: Text(product.name),
                      onTap: () => Navigator.pop(context, product),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
