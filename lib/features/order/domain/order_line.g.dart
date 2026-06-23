// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderLine _$OrderLineFromJson(Map<String, dynamic> json) => _OrderLine(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  description: json['description'] as String? ?? '',
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
  uomName: json['uomName'] as String? ?? '',
  priceUnit: (json['priceUnit'] as num?)?.toDouble() ?? 0.0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  taxNames:
      (json['taxNames'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$OrderLineToJson(_OrderLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'description': instance.description,
      'quantity': instance.quantity,
      'uomName': instance.uomName,
      'priceUnit': instance.priceUnit,
      'discount': instance.discount,
      'subtotal': instance.subtotal,
      'taxNames': instance.taxNames,
    };
