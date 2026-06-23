import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_line.freezed.dart';
part 'order_line.g.dart';

@freezed
abstract class OrderLine with _$OrderLine {
  const factory OrderLine({
    required int id,
    required int productId,
    required String productName,
    @Default('') String description,
    @Default(1.0) double quantity,
    @Default('') String uomName,
    @Default(0.0) double priceUnit,
    @Default(0.0) double discount,
    @Default(0.0) double subtotal,
    @Default(<String>[]) List<String> taxNames,
  }) = _OrderLine;

  factory OrderLine.fromJson(Map<String, dynamic> json) =>
      _$OrderLineFromJson(json);

  factory OrderLine.fromOdoo(Map<String, dynamic> json) => OrderLine(
        id: json['id'] as int? ?? 0,
        productId: _many2oneId(json['product_id']) ?? 0,
        productName: _many2oneName(json['product_id']) ?? '',
        description: json['name']?.toString() ?? '',
        quantity: (json['product_uom_qty'] as num?)?.toDouble() ?? 1,
        uomName: _many2oneName(json['product_uom']) ?? '',
        priceUnit: (json['price_unit'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        subtotal: (json['price_subtotal'] as num?)?.toDouble() ?? 0,
        taxNames: _taxNames(json['tax_id']),
      );

  /// Draft line for create form (no id yet).
  factory OrderLine.draft({
    required int productId,
    required String productName,
    String description = '',
    double quantity = 1,
    double priceUnit = 0,
  }) =>
      OrderLine(
        id: 0,
        productId: productId,
        productName: productName,
        description: description,
        quantity: quantity,
        priceUnit: priceUnit,
        subtotal: quantity * priceUnit,
      );
}

int? _many2oneId(dynamic value) {
  if (value is List && value.isNotEmpty) return value.first as int?;
  return null;
}

String? _many2oneName(dynamic value) {
  if (value is List && value.length > 1) return value[1]?.toString();
  if (value is bool && !value) return null;
  return value?.toString();
}

List<String> _taxNames(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<List>()
      .where((e) => e.length > 1)
      .map((e) => e[1].toString())
      .toList();
}
