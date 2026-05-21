// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lead {

 int get id; String get customerName; String get phone; String get email; String get salesperson; LeadStage get stage; String get source; DateTime get createdAt; String? get title; String? get note; String? get companyName; String? get street; String? get city; String? get country; String? get website; String? get mobile; String? get jobPosition; double? get expectedRevenue; double? get probability; LeadPriority get priority; DateTime? get dateDeadline; DateTime? get lastUpdated; List<String> get tags;
/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadCopyWith<Lead> get copyWith => _$LeadCopyWithImpl<Lead>(this as Lead, _$identity);

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.website, website) || other.website == website)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.jobPosition, jobPosition) || other.jobPosition == jobPosition)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue)&&(identical(other.probability, probability) || other.probability == probability)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,phone,email,salesperson,stage,source,createdAt,title,note,companyName,street,city,country,website,mobile,jobPosition,expectedRevenue,probability,priority,dateDeadline,lastUpdated,const DeepCollectionEquality().hash(tags)]);

@override
String toString() {
  return 'Lead(id: $id, customerName: $customerName, phone: $phone, email: $email, salesperson: $salesperson, stage: $stage, source: $source, createdAt: $createdAt, title: $title, note: $note, companyName: $companyName, street: $street, city: $city, country: $country, website: $website, mobile: $mobile, jobPosition: $jobPosition, expectedRevenue: $expectedRevenue, probability: $probability, priority: $priority, dateDeadline: $dateDeadline, lastUpdated: $lastUpdated, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $LeadCopyWith<$Res>  {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) _then) = _$LeadCopyWithImpl;
@useResult
$Res call({
 int id, String customerName, String phone, String email, String salesperson, LeadStage stage, String source, DateTime createdAt, String? title, String? note, String? companyName, String? street, String? city, String? country, String? website, String? mobile, String? jobPosition, double? expectedRevenue, double? probability, LeadPriority priority, DateTime? dateDeadline, DateTime? lastUpdated, List<String> tags
});




}
/// @nodoc
class _$LeadCopyWithImpl<$Res>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._self, this._then);

  final Lead _self;
  final $Res Function(Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerName = null,Object? phone = null,Object? email = null,Object? salesperson = null,Object? stage = null,Object? source = null,Object? createdAt = null,Object? title = freezed,Object? note = freezed,Object? companyName = freezed,Object? street = freezed,Object? city = freezed,Object? country = freezed,Object? website = freezed,Object? mobile = freezed,Object? jobPosition = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? priority = null,Object? dateDeadline = freezed,Object? lastUpdated = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as LeadStage,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,jobPosition: freezed == jobPosition ? _self.jobPosition : jobPosition // ignore: cast_nullable_to_non_nullable
as String?,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as LeadPriority,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Lead].
extension LeadPatterns on Lead {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lead value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lead value)  $default,){
final _that = this;
switch (_that) {
case _Lead():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lead value)?  $default,){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String customerName,  String phone,  String email,  String salesperson,  LeadStage stage,  String source,  DateTime createdAt,  String? title,  String? note,  String? companyName,  String? street,  String? city,  String? country,  String? website,  String? mobile,  String? jobPosition,  double? expectedRevenue,  double? probability,  LeadPriority priority,  DateTime? dateDeadline,  DateTime? lastUpdated,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.customerName,_that.phone,_that.email,_that.salesperson,_that.stage,_that.source,_that.createdAt,_that.title,_that.note,_that.companyName,_that.street,_that.city,_that.country,_that.website,_that.mobile,_that.jobPosition,_that.expectedRevenue,_that.probability,_that.priority,_that.dateDeadline,_that.lastUpdated,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String customerName,  String phone,  String email,  String salesperson,  LeadStage stage,  String source,  DateTime createdAt,  String? title,  String? note,  String? companyName,  String? street,  String? city,  String? country,  String? website,  String? mobile,  String? jobPosition,  double? expectedRevenue,  double? probability,  LeadPriority priority,  DateTime? dateDeadline,  DateTime? lastUpdated,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _Lead():
return $default(_that.id,_that.customerName,_that.phone,_that.email,_that.salesperson,_that.stage,_that.source,_that.createdAt,_that.title,_that.note,_that.companyName,_that.street,_that.city,_that.country,_that.website,_that.mobile,_that.jobPosition,_that.expectedRevenue,_that.probability,_that.priority,_that.dateDeadline,_that.lastUpdated,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String customerName,  String phone,  String email,  String salesperson,  LeadStage stage,  String source,  DateTime createdAt,  String? title,  String? note,  String? companyName,  String? street,  String? city,  String? country,  String? website,  String? mobile,  String? jobPosition,  double? expectedRevenue,  double? probability,  LeadPriority priority,  DateTime? dateDeadline,  DateTime? lastUpdated,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.customerName,_that.phone,_that.email,_that.salesperson,_that.stage,_that.source,_that.createdAt,_that.title,_that.note,_that.companyName,_that.street,_that.city,_that.country,_that.website,_that.mobile,_that.jobPosition,_that.expectedRevenue,_that.probability,_that.priority,_that.dateDeadline,_that.lastUpdated,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lead implements Lead {
  const _Lead({required this.id, required this.customerName, required this.phone, required this.email, required this.salesperson, required this.stage, required this.source, required this.createdAt, this.title, this.note, this.companyName, this.street, this.city, this.country, this.website, this.mobile, this.jobPosition, this.expectedRevenue, this.probability, this.priority = LeadPriority.normal, this.dateDeadline, this.lastUpdated, final  List<String> tags = const <String>[]}): _tags = tags;
  factory _Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

@override final  int id;
@override final  String customerName;
@override final  String phone;
@override final  String email;
@override final  String salesperson;
@override final  LeadStage stage;
@override final  String source;
@override final  DateTime createdAt;
@override final  String? title;
@override final  String? note;
@override final  String? companyName;
@override final  String? street;
@override final  String? city;
@override final  String? country;
@override final  String? website;
@override final  String? mobile;
@override final  String? jobPosition;
@override final  double? expectedRevenue;
@override final  double? probability;
@override@JsonKey() final  LeadPriority priority;
@override final  DateTime? dateDeadline;
@override final  DateTime? lastUpdated;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadCopyWith<_Lead> get copyWith => __$LeadCopyWithImpl<_Lead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.website, website) || other.website == website)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.jobPosition, jobPosition) || other.jobPosition == jobPosition)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue)&&(identical(other.probability, probability) || other.probability == probability)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,phone,email,salesperson,stage,source,createdAt,title,note,companyName,street,city,country,website,mobile,jobPosition,expectedRevenue,probability,priority,dateDeadline,lastUpdated,const DeepCollectionEquality().hash(_tags)]);

@override
String toString() {
  return 'Lead(id: $id, customerName: $customerName, phone: $phone, email: $email, salesperson: $salesperson, stage: $stage, source: $source, createdAt: $createdAt, title: $title, note: $note, companyName: $companyName, street: $street, city: $city, country: $country, website: $website, mobile: $mobile, jobPosition: $jobPosition, expectedRevenue: $expectedRevenue, probability: $probability, priority: $priority, dateDeadline: $dateDeadline, lastUpdated: $lastUpdated, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$LeadCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$LeadCopyWith(_Lead value, $Res Function(_Lead) _then) = __$LeadCopyWithImpl;
@override @useResult
$Res call({
 int id, String customerName, String phone, String email, String salesperson, LeadStage stage, String source, DateTime createdAt, String? title, String? note, String? companyName, String? street, String? city, String? country, String? website, String? mobile, String? jobPosition, double? expectedRevenue, double? probability, LeadPriority priority, DateTime? dateDeadline, DateTime? lastUpdated, List<String> tags
});




}
/// @nodoc
class __$LeadCopyWithImpl<$Res>
    implements _$LeadCopyWith<$Res> {
  __$LeadCopyWithImpl(this._self, this._then);

  final _Lead _self;
  final $Res Function(_Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerName = null,Object? phone = null,Object? email = null,Object? salesperson = null,Object? stage = null,Object? source = null,Object? createdAt = null,Object? title = freezed,Object? note = freezed,Object? companyName = freezed,Object? street = freezed,Object? city = freezed,Object? country = freezed,Object? website = freezed,Object? mobile = freezed,Object? jobPosition = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? priority = null,Object? dateDeadline = freezed,Object? lastUpdated = freezed,Object? tags = null,}) {
  return _then(_Lead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as LeadStage,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,jobPosition: freezed == jobPosition ? _self.jobPosition : jobPosition // ignore: cast_nullable_to_non_nullable
as String?,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as LeadPriority,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
