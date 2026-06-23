// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: (json['id'] as num).toInt(),
  number: json['number'] as String,
  customer: json['customer'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  partnerId: (json['partnerId'] as num?)?.toInt(),
  opportunityId: (json['opportunityId'] as num?)?.toInt(),
  origin: json['origin'] as String?,
  validityDate: json['validityDate'] == null
      ? null
      : DateTime.parse(json['validityDate'] as String),
  note: json['note'] as String?,
  userId: (json['userId'] as num?)?.toInt(),
  teamId: (json['teamId'] as num?)?.toInt(),
  pricelistId: (json['pricelistId'] as num?)?.toInt(),
  paymentTermId: (json['paymentTermId'] as num?)?.toInt(),
  clientOrderRef: json['clientOrderRef'] as String?,
  salespersonName: json['salespersonName'] as String?,
  teamName: json['teamName'] as String?,
  pricelistName: json['pricelistName'] as String?,
  paymentTermName: json['paymentTermName'] as String?,
  opportunityName: json['opportunityName'] as String?,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderLine>[],
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'customer': instance.customer,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'partnerId': instance.partnerId,
  'opportunityId': instance.opportunityId,
  'origin': instance.origin,
  'validityDate': instance.validityDate?.toIso8601String(),
  'note': instance.note,
  'userId': instance.userId,
  'teamId': instance.teamId,
  'pricelistId': instance.pricelistId,
  'paymentTermId': instance.paymentTermId,
  'clientOrderRef': instance.clientOrderRef,
  'salespersonName': instance.salespersonName,
  'teamName': instance.teamName,
  'pricelistName': instance.pricelistName,
  'paymentTermName': instance.paymentTermName,
  'opportunityName': instance.opportunityName,
  'lines': instance.lines,
};

const _$OrderStatusEnumMap = {
  OrderStatus.draft: 'draft',
  OrderStatus.sent: 'sent',
  OrderStatus.sale: 'sale',
  OrderStatus.cancel: 'cancel',
};
