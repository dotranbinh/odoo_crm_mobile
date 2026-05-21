// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kpi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Kpi _$KpiFromJson(Map<String, dynamic> json) => _Kpi(
  id: json['id'] as String,
  title: json['title'] as String,
  value: json['value'] as String,
  iconName: json['iconName'] as String,
  trend: json['trend'] as String?,
);

Map<String, dynamic> _$KpiToJson(_Kpi instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'value': instance.value,
  'iconName': instance.iconName,
  'trend': instance.trend,
};
