// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kpi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Kpi {

 String get id; String get title; String get value; String get iconName; String? get trend;
/// Create a copy of Kpi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KpiCopyWith<Kpi> get copyWith => _$KpiCopyWithImpl<Kpi>(this as Kpi, _$identity);

  /// Serializes this Kpi to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Kpi&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.trend, trend) || other.trend == trend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,value,iconName,trend);

@override
String toString() {
  return 'Kpi(id: $id, title: $title, value: $value, iconName: $iconName, trend: $trend)';
}


}

/// @nodoc
abstract mixin class $KpiCopyWith<$Res>  {
  factory $KpiCopyWith(Kpi value, $Res Function(Kpi) _then) = _$KpiCopyWithImpl;
@useResult
$Res call({
 String id, String title, String value, String iconName, String? trend
});




}
/// @nodoc
class _$KpiCopyWithImpl<$Res>
    implements $KpiCopyWith<$Res> {
  _$KpiCopyWithImpl(this._self, this._then);

  final Kpi _self;
  final $Res Function(Kpi) _then;

/// Create a copy of Kpi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? value = null,Object? iconName = null,Object? trend = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Kpi].
extension KpiPatterns on Kpi {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Kpi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Kpi() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Kpi value)  $default,){
final _that = this;
switch (_that) {
case _Kpi():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Kpi value)?  $default,){
final _that = this;
switch (_that) {
case _Kpi() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String value,  String iconName,  String? trend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Kpi() when $default != null:
return $default(_that.id,_that.title,_that.value,_that.iconName,_that.trend);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String value,  String iconName,  String? trend)  $default,) {final _that = this;
switch (_that) {
case _Kpi():
return $default(_that.id,_that.title,_that.value,_that.iconName,_that.trend);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String value,  String iconName,  String? trend)?  $default,) {final _that = this;
switch (_that) {
case _Kpi() when $default != null:
return $default(_that.id,_that.title,_that.value,_that.iconName,_that.trend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Kpi implements Kpi {
  const _Kpi({required this.id, required this.title, required this.value, required this.iconName, this.trend});
  factory _Kpi.fromJson(Map<String, dynamic> json) => _$KpiFromJson(json);

@override final  String id;
@override final  String title;
@override final  String value;
@override final  String iconName;
@override final  String? trend;

/// Create a copy of Kpi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KpiCopyWith<_Kpi> get copyWith => __$KpiCopyWithImpl<_Kpi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KpiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Kpi&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.trend, trend) || other.trend == trend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,value,iconName,trend);

@override
String toString() {
  return 'Kpi(id: $id, title: $title, value: $value, iconName: $iconName, trend: $trend)';
}


}

/// @nodoc
abstract mixin class _$KpiCopyWith<$Res> implements $KpiCopyWith<$Res> {
  factory _$KpiCopyWith(_Kpi value, $Res Function(_Kpi) _then) = __$KpiCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String value, String iconName, String? trend
});




}
/// @nodoc
class __$KpiCopyWithImpl<$Res>
    implements _$KpiCopyWith<$Res> {
  __$KpiCopyWithImpl(this._self, this._then);

  final _Kpi _self;
  final $Res Function(_Kpi) _then;

/// Create a copy of Kpi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? value = null,Object? iconName = null,Object? trend = freezed,}) {
  return _then(_Kpi(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
