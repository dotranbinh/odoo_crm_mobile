import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('done')
  done,
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
      );
}

OrderStatus _mapStatus(String? state) {
  switch (state) {
    case 'sale':
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'done':
      return OrderStatus.done;
    default:
      return OrderStatus.draft;
  }
}

String? _many2oneName(dynamic value) {
  if (value is List && value.length > 1) return value[1]?.toString();
  return value?.toString();
}
