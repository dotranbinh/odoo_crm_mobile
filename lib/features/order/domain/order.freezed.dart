// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 int get id; String get number; String get customer; double get amount; String get currency; OrderStatus get status; DateTime get createdAt; int? get partnerId; int? get opportunityId; String? get origin; DateTime? get validityDate; String? get note; int? get userId; int? get teamId; int? get pricelistId; int? get paymentTermId; String? get clientOrderRef; String? get salespersonName; String? get teamName; String? get pricelistName; String? get paymentTermName; String? get opportunityName; List<OrderLine> get lines;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.opportunityId, opportunityId) || other.opportunityId == opportunityId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.validityDate, validityDate) || other.validityDate == validityDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.pricelistId, pricelistId) || other.pricelistId == pricelistId)&&(identical(other.paymentTermId, paymentTermId) || other.paymentTermId == paymentTermId)&&(identical(other.clientOrderRef, clientOrderRef) || other.clientOrderRef == clientOrderRef)&&(identical(other.salespersonName, salespersonName) || other.salespersonName == salespersonName)&&(identical(other.teamName, teamName) || other.teamName == teamName)&&(identical(other.pricelistName, pricelistName) || other.pricelistName == pricelistName)&&(identical(other.paymentTermName, paymentTermName) || other.paymentTermName == paymentTermName)&&(identical(other.opportunityName, opportunityName) || other.opportunityName == opportunityName)&&const DeepCollectionEquality().equals(other.lines, lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,number,customer,amount,currency,status,createdAt,partnerId,opportunityId,origin,validityDate,note,userId,teamId,pricelistId,paymentTermId,clientOrderRef,salespersonName,teamName,pricelistName,paymentTermName,opportunityName,const DeepCollectionEquality().hash(lines)]);

@override
String toString() {
  return 'Order(id: $id, number: $number, customer: $customer, amount: $amount, currency: $currency, status: $status, createdAt: $createdAt, partnerId: $partnerId, opportunityId: $opportunityId, origin: $origin, validityDate: $validityDate, note: $note, userId: $userId, teamId: $teamId, pricelistId: $pricelistId, paymentTermId: $paymentTermId, clientOrderRef: $clientOrderRef, salespersonName: $salespersonName, teamName: $teamName, pricelistName: $pricelistName, paymentTermName: $paymentTermName, opportunityName: $opportunityName, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 int id, String number, String customer, double amount, String currency, OrderStatus status, DateTime createdAt, int? partnerId, int? opportunityId, String? origin, DateTime? validityDate, String? note, int? userId, int? teamId, int? pricelistId, int? paymentTermId, String? clientOrderRef, String? salespersonName, String? teamName, String? pricelistName, String? paymentTermName, String? opportunityName, List<OrderLine> lines
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? customer = null,Object? amount = null,Object? currency = null,Object? status = null,Object? createdAt = null,Object? partnerId = freezed,Object? opportunityId = freezed,Object? origin = freezed,Object? validityDate = freezed,Object? note = freezed,Object? userId = freezed,Object? teamId = freezed,Object? pricelistId = freezed,Object? paymentTermId = freezed,Object? clientOrderRef = freezed,Object? salespersonName = freezed,Object? teamName = freezed,Object? pricelistName = freezed,Object? paymentTermName = freezed,Object? opportunityName = freezed,Object? lines = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int?,opportunityId: freezed == opportunityId ? _self.opportunityId : opportunityId // ignore: cast_nullable_to_non_nullable
as int?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,validityDate: freezed == validityDate ? _self.validityDate : validityDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,pricelistId: freezed == pricelistId ? _self.pricelistId : pricelistId // ignore: cast_nullable_to_non_nullable
as int?,paymentTermId: freezed == paymentTermId ? _self.paymentTermId : paymentTermId // ignore: cast_nullable_to_non_nullable
as int?,clientOrderRef: freezed == clientOrderRef ? _self.clientOrderRef : clientOrderRef // ignore: cast_nullable_to_non_nullable
as String?,salespersonName: freezed == salespersonName ? _self.salespersonName : salespersonName // ignore: cast_nullable_to_non_nullable
as String?,teamName: freezed == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String?,pricelistName: freezed == pricelistName ? _self.pricelistName : pricelistName // ignore: cast_nullable_to_non_nullable
as String?,paymentTermName: freezed == paymentTermName ? _self.paymentTermName : paymentTermName // ignore: cast_nullable_to_non_nullable
as String?,opportunityName: freezed == opportunityName ? _self.opportunityName : opportunityName // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String number,  String customer,  double amount,  String currency,  OrderStatus status,  DateTime createdAt,  int? partnerId,  int? opportunityId,  String? origin,  DateTime? validityDate,  String? note,  int? userId,  int? teamId,  int? pricelistId,  int? paymentTermId,  String? clientOrderRef,  String? salespersonName,  String? teamName,  String? pricelistName,  String? paymentTermName,  String? opportunityName,  List<OrderLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customer,_that.amount,_that.currency,_that.status,_that.createdAt,_that.partnerId,_that.opportunityId,_that.origin,_that.validityDate,_that.note,_that.userId,_that.teamId,_that.pricelistId,_that.paymentTermId,_that.clientOrderRef,_that.salespersonName,_that.teamName,_that.pricelistName,_that.paymentTermName,_that.opportunityName,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String number,  String customer,  double amount,  String currency,  OrderStatus status,  DateTime createdAt,  int? partnerId,  int? opportunityId,  String? origin,  DateTime? validityDate,  String? note,  int? userId,  int? teamId,  int? pricelistId,  int? paymentTermId,  String? clientOrderRef,  String? salespersonName,  String? teamName,  String? pricelistName,  String? paymentTermName,  String? opportunityName,  List<OrderLine> lines)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.number,_that.customer,_that.amount,_that.currency,_that.status,_that.createdAt,_that.partnerId,_that.opportunityId,_that.origin,_that.validityDate,_that.note,_that.userId,_that.teamId,_that.pricelistId,_that.paymentTermId,_that.clientOrderRef,_that.salespersonName,_that.teamName,_that.pricelistName,_that.paymentTermName,_that.opportunityName,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String number,  String customer,  double amount,  String currency,  OrderStatus status,  DateTime createdAt,  int? partnerId,  int? opportunityId,  String? origin,  DateTime? validityDate,  String? note,  int? userId,  int? teamId,  int? pricelistId,  int? paymentTermId,  String? clientOrderRef,  String? salespersonName,  String? teamName,  String? pricelistName,  String? paymentTermName,  String? opportunityName,  List<OrderLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customer,_that.amount,_that.currency,_that.status,_that.createdAt,_that.partnerId,_that.opportunityId,_that.origin,_that.validityDate,_that.note,_that.userId,_that.teamId,_that.pricelistId,_that.paymentTermId,_that.clientOrderRef,_that.salespersonName,_that.teamName,_that.pricelistName,_that.paymentTermName,_that.opportunityName,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.number, required this.customer, required this.amount, required this.currency, required this.status, required this.createdAt, this.partnerId, this.opportunityId, this.origin, this.validityDate, this.note, this.userId, this.teamId, this.pricelistId, this.paymentTermId, this.clientOrderRef, this.salespersonName, this.teamName, this.pricelistName, this.paymentTermName, this.opportunityName, final  List<OrderLine> lines = const <OrderLine>[]}): _lines = lines;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  int id;
@override final  String number;
@override final  String customer;
@override final  double amount;
@override final  String currency;
@override final  OrderStatus status;
@override final  DateTime createdAt;
@override final  int? partnerId;
@override final  int? opportunityId;
@override final  String? origin;
@override final  DateTime? validityDate;
@override final  String? note;
@override final  int? userId;
@override final  int? teamId;
@override final  int? pricelistId;
@override final  int? paymentTermId;
@override final  String? clientOrderRef;
@override final  String? salespersonName;
@override final  String? teamName;
@override final  String? pricelistName;
@override final  String? paymentTermName;
@override final  String? opportunityName;
 final  List<OrderLine> _lines;
@override@JsonKey() List<OrderLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.opportunityId, opportunityId) || other.opportunityId == opportunityId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.validityDate, validityDate) || other.validityDate == validityDate)&&(identical(other.note, note) || other.note == note)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.pricelistId, pricelistId) || other.pricelistId == pricelistId)&&(identical(other.paymentTermId, paymentTermId) || other.paymentTermId == paymentTermId)&&(identical(other.clientOrderRef, clientOrderRef) || other.clientOrderRef == clientOrderRef)&&(identical(other.salespersonName, salespersonName) || other.salespersonName == salespersonName)&&(identical(other.teamName, teamName) || other.teamName == teamName)&&(identical(other.pricelistName, pricelistName) || other.pricelistName == pricelistName)&&(identical(other.paymentTermName, paymentTermName) || other.paymentTermName == paymentTermName)&&(identical(other.opportunityName, opportunityName) || other.opportunityName == opportunityName)&&const DeepCollectionEquality().equals(other._lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,number,customer,amount,currency,status,createdAt,partnerId,opportunityId,origin,validityDate,note,userId,teamId,pricelistId,paymentTermId,clientOrderRef,salespersonName,teamName,pricelistName,paymentTermName,opportunityName,const DeepCollectionEquality().hash(_lines)]);

@override
String toString() {
  return 'Order(id: $id, number: $number, customer: $customer, amount: $amount, currency: $currency, status: $status, createdAt: $createdAt, partnerId: $partnerId, opportunityId: $opportunityId, origin: $origin, validityDate: $validityDate, note: $note, userId: $userId, teamId: $teamId, pricelistId: $pricelistId, paymentTermId: $paymentTermId, clientOrderRef: $clientOrderRef, salespersonName: $salespersonName, teamName: $teamName, pricelistName: $pricelistName, paymentTermName: $paymentTermName, opportunityName: $opportunityName, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String number, String customer, double amount, String currency, OrderStatus status, DateTime createdAt, int? partnerId, int? opportunityId, String? origin, DateTime? validityDate, String? note, int? userId, int? teamId, int? pricelistId, int? paymentTermId, String? clientOrderRef, String? salespersonName, String? teamName, String? pricelistName, String? paymentTermName, String? opportunityName, List<OrderLine> lines
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? customer = null,Object? amount = null,Object? currency = null,Object? status = null,Object? createdAt = null,Object? partnerId = freezed,Object? opportunityId = freezed,Object? origin = freezed,Object? validityDate = freezed,Object? note = freezed,Object? userId = freezed,Object? teamId = freezed,Object? pricelistId = freezed,Object? paymentTermId = freezed,Object? clientOrderRef = freezed,Object? salespersonName = freezed,Object? teamName = freezed,Object? pricelistName = freezed,Object? paymentTermName = freezed,Object? opportunityName = freezed,Object? lines = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as int?,opportunityId: freezed == opportunityId ? _self.opportunityId : opportunityId // ignore: cast_nullable_to_non_nullable
as int?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String?,validityDate: freezed == validityDate ? _self.validityDate : validityDate // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,pricelistId: freezed == pricelistId ? _self.pricelistId : pricelistId // ignore: cast_nullable_to_non_nullable
as int?,paymentTermId: freezed == paymentTermId ? _self.paymentTermId : paymentTermId // ignore: cast_nullable_to_non_nullable
as int?,clientOrderRef: freezed == clientOrderRef ? _self.clientOrderRef : clientOrderRef // ignore: cast_nullable_to_non_nullable
as String?,salespersonName: freezed == salespersonName ? _self.salespersonName : salespersonName // ignore: cast_nullable_to_non_nullable
as String?,teamName: freezed == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String?,pricelistName: freezed == pricelistName ? _self.pricelistName : pricelistName // ignore: cast_nullable_to_non_nullable
as String?,paymentTermName: freezed == paymentTermName ? _self.paymentTermName : paymentTermName // ignore: cast_nullable_to_non_nullable
as String?,opportunityName: freezed == opportunityName ? _self.opportunityName : opportunityName // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,
  ));
}


}

// dart format on
