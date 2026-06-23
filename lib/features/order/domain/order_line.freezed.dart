// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderLine {

 int get id; int get productId; String get productName; String get description; double get quantity; String get uomName; double get priceUnit; double get discount; double get subtotal; List<String> get taxNames;
/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderLineCopyWith<OrderLine> get copyWith => _$OrderLineCopyWithImpl<OrderLine>(this as OrderLine, _$identity);

  /// Serializes this OrderLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.uomName, uomName) || other.uomName == uomName)&&(identical(other.priceUnit, priceUnit) || other.priceUnit == priceUnit)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&const DeepCollectionEquality().equals(other.taxNames, taxNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,description,quantity,uomName,priceUnit,discount,subtotal,const DeepCollectionEquality().hash(taxNames));

@override
String toString() {
  return 'OrderLine(id: $id, productId: $productId, productName: $productName, description: $description, quantity: $quantity, uomName: $uomName, priceUnit: $priceUnit, discount: $discount, subtotal: $subtotal, taxNames: $taxNames)';
}


}

/// @nodoc
abstract mixin class $OrderLineCopyWith<$Res>  {
  factory $OrderLineCopyWith(OrderLine value, $Res Function(OrderLine) _then) = _$OrderLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String productName, String description, double quantity, String uomName, double priceUnit, double discount, double subtotal, List<String> taxNames
});




}
/// @nodoc
class _$OrderLineCopyWithImpl<$Res>
    implements $OrderLineCopyWith<$Res> {
  _$OrderLineCopyWithImpl(this._self, this._then);

  final OrderLine _self;
  final $Res Function(OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? description = null,Object? quantity = null,Object? uomName = null,Object? priceUnit = null,Object? discount = null,Object? subtotal = null,Object? taxNames = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,uomName: null == uomName ? _self.uomName : uomName // ignore: cast_nullable_to_non_nullable
as String,priceUnit: null == priceUnit ? _self.priceUnit : priceUnit // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxNames: null == taxNames ? _self.taxNames : taxNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderLine].
extension OrderLinePatterns on OrderLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderLine value)  $default,){
final _that = this;
switch (_that) {
case _OrderLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String productName,  String description,  double quantity,  String uomName,  double priceUnit,  double discount,  double subtotal,  List<String> taxNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.description,_that.quantity,_that.uomName,_that.priceUnit,_that.discount,_that.subtotal,_that.taxNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String productName,  String description,  double quantity,  String uomName,  double priceUnit,  double discount,  double subtotal,  List<String> taxNames)  $default,) {final _that = this;
switch (_that) {
case _OrderLine():
return $default(_that.id,_that.productId,_that.productName,_that.description,_that.quantity,_that.uomName,_that.priceUnit,_that.discount,_that.subtotal,_that.taxNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String productName,  String description,  double quantity,  String uomName,  double priceUnit,  double discount,  double subtotal,  List<String> taxNames)?  $default,) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.description,_that.quantity,_that.uomName,_that.priceUnit,_that.discount,_that.subtotal,_that.taxNames);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderLine implements OrderLine {
  const _OrderLine({required this.id, required this.productId, required this.productName, this.description = '', this.quantity = 1.0, this.uomName = '', this.priceUnit = 0.0, this.discount = 0.0, this.subtotal = 0.0, final  List<String> taxNames = const <String>[]}): _taxNames = taxNames;
  factory _OrderLine.fromJson(Map<String, dynamic> json) => _$OrderLineFromJson(json);

@override final  int id;
@override final  int productId;
@override final  String productName;
@override@JsonKey() final  String description;
@override@JsonKey() final  double quantity;
@override@JsonKey() final  String uomName;
@override@JsonKey() final  double priceUnit;
@override@JsonKey() final  double discount;
@override@JsonKey() final  double subtotal;
 final  List<String> _taxNames;
@override@JsonKey() List<String> get taxNames {
  if (_taxNames is EqualUnmodifiableListView) return _taxNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taxNames);
}


/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderLineCopyWith<_OrderLine> get copyWith => __$OrderLineCopyWithImpl<_OrderLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.uomName, uomName) || other.uomName == uomName)&&(identical(other.priceUnit, priceUnit) || other.priceUnit == priceUnit)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&const DeepCollectionEquality().equals(other._taxNames, _taxNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,description,quantity,uomName,priceUnit,discount,subtotal,const DeepCollectionEquality().hash(_taxNames));

@override
String toString() {
  return 'OrderLine(id: $id, productId: $productId, productName: $productName, description: $description, quantity: $quantity, uomName: $uomName, priceUnit: $priceUnit, discount: $discount, subtotal: $subtotal, taxNames: $taxNames)';
}


}

/// @nodoc
abstract mixin class _$OrderLineCopyWith<$Res> implements $OrderLineCopyWith<$Res> {
  factory _$OrderLineCopyWith(_OrderLine value, $Res Function(_OrderLine) _then) = __$OrderLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String productName, String description, double quantity, String uomName, double priceUnit, double discount, double subtotal, List<String> taxNames
});




}
/// @nodoc
class __$OrderLineCopyWithImpl<$Res>
    implements _$OrderLineCopyWith<$Res> {
  __$OrderLineCopyWithImpl(this._self, this._then);

  final _OrderLine _self;
  final $Res Function(_OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? description = null,Object? quantity = null,Object? uomName = null,Object? priceUnit = null,Object? discount = null,Object? subtotal = null,Object? taxNames = null,}) {
  return _then(_OrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,uomName: null == uomName ? _self.uomName : uomName // ignore: cast_nullable_to_non_nullable
as String,priceUnit: null == priceUnit ? _self.priceUnit : priceUnit // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxNames: null == taxNames ? _self._taxNames : taxNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
