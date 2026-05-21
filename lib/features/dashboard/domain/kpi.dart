import 'package:freezed_annotation/freezed_annotation.dart';

part 'kpi.freezed.dart';
part 'kpi.g.dart';

@freezed
abstract class Kpi with _$Kpi {
  const factory Kpi({
    required String id,
    required String title,
    required String value,
    required String iconName,
    String? trend,
  }) = _Kpi;

  factory Kpi.fromJson(Map<String, dynamic> json) => _$KpiFromJson(json);
}
