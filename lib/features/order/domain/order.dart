import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_line.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('sale')
  sale,
  @JsonValue('cancel')
  cancel,
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    required int id,
    required String number,
    required String customer,
    required double amount,
    required String currency,
    required OrderStatus status,
    required DateTime createdAt,
    int? partnerId,
    int? opportunityId,
    String? origin,
    DateTime? validityDate,
    String? note,
    int? userId,
    int? teamId,
    int? pricelistId,
    int? paymentTermId,
    String? clientOrderRef,
    String? salespersonName,
    String? teamName,
    String? pricelistName,
    String? paymentTermName,
    String? opportunityName,
    @Default(<OrderLine>[]) List<OrderLine> lines,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  factory Order.fromOdoo(Map<String, dynamic> json) => Order(
        id: json['id'] as int? ?? 0,
        number: json['name'] as String? ?? '',
        customer: _many2oneName(json['partner_id']) ?? '',
        amount: (json['amount_total'] as num?)?.toDouble() ?? 0,
        currency: _many2oneName(json['currency_id']) ?? 'USD',
        status: _mapStatus(json['state'] as String?),
        createdAt: json['date_order'] != null
            ? DateTime.tryParse(json['date_order'] as String) ?? DateTime.now()
            : DateTime.now(),
        partnerId: _many2oneId(json['partner_id']),
        opportunityId: _many2oneId(json['opportunity_id']),
        origin: json['origin']?.toString(),
        validityDate: _date(json['validity_date']),
        note: json['note']?.toString(),
        userId: _many2oneId(json['user_id']),
        teamId: _many2oneId(json['team_id']),
        pricelistId: _many2oneId(json['pricelist_id']),
        paymentTermId: _many2oneId(json['payment_term_id']),
        clientOrderRef: json['client_order_ref']?.toString(),
        salespersonName: _many2oneName(json['user_id']),
        teamName: _many2oneName(json['team_id']),
        pricelistName: _many2oneName(json['pricelist_id']),
        paymentTermName: _many2oneName(json['payment_term_id']),
        opportunityName: _many2oneName(json['opportunity_id']),
        lines: _parseLines(json['order_line']),
      );
}

OrderStatus _mapStatus(String? state) {
  switch (state) {
    case 'sent':
      return OrderStatus.sent;
    case 'sale':
      return OrderStatus.sale;
    case 'cancel':
      return OrderStatus.cancel;
    default:
      return OrderStatus.draft;
  }
}

DateTime? _date(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
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

List<OrderLine> _parseLines(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map<String, dynamic>) OrderLine.fromOdoo(item),
  ];
}

/// Maps OrderStatus to Odoo state domain filter values.
String? orderStatusOdooState(OrderStatus? status) {
  if (status == null) return null;
  return switch (status) {
    OrderStatus.draft => 'draft',
    OrderStatus.sent => 'sent',
    OrderStatus.sale => 'sale',
    OrderStatus.cancel => 'cancel',
  };
}

extension OrderX on Order {
  bool get isEditable =>
      status == OrderStatus.draft || status == OrderStatus.sent;
}
