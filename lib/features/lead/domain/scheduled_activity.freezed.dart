// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduledActivity {

 int get id; String get summary; String get activityTypeName; int get activityTypeId; DateTime get dateDeadline; String get assigneeName; int? get assigneeId; ScheduledActivityState get state; bool get isOverdue;
/// Create a copy of ScheduledActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledActivityCopyWith<ScheduledActivity> get copyWith => _$ScheduledActivityCopyWithImpl<ScheduledActivity>(this as ScheduledActivity, _$identity);

  /// Serializes this ScheduledActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.activityTypeName, activityTypeName) || other.activityTypeName == activityTypeName)&&(identical(other.activityTypeId, activityTypeId) || other.activityTypeId == activityTypeId)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.assigneeName, assigneeName) || other.assigneeName == assigneeName)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summary,activityTypeName,activityTypeId,dateDeadline,assigneeName,assigneeId,state,isOverdue);

@override
String toString() {
  return 'ScheduledActivity(id: $id, summary: $summary, activityTypeName: $activityTypeName, activityTypeId: $activityTypeId, dateDeadline: $dateDeadline, assigneeName: $assigneeName, assigneeId: $assigneeId, state: $state, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class $ScheduledActivityCopyWith<$Res>  {
  factory $ScheduledActivityCopyWith(ScheduledActivity value, $Res Function(ScheduledActivity) _then) = _$ScheduledActivityCopyWithImpl;
@useResult
$Res call({
 int id, String summary, String activityTypeName, int activityTypeId, DateTime dateDeadline, String assigneeName, int? assigneeId, ScheduledActivityState state, bool isOverdue
});




}
/// @nodoc
class _$ScheduledActivityCopyWithImpl<$Res>
    implements $ScheduledActivityCopyWith<$Res> {
  _$ScheduledActivityCopyWithImpl(this._self, this._then);

  final ScheduledActivity _self;
  final $Res Function(ScheduledActivity) _then;

/// Create a copy of ScheduledActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = null,Object? activityTypeName = null,Object? activityTypeId = null,Object? dateDeadline = null,Object? assigneeName = null,Object? assigneeId = freezed,Object? state = null,Object? isOverdue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,activityTypeName: null == activityTypeName ? _self.activityTypeName : activityTypeName // ignore: cast_nullable_to_non_nullable
as String,activityTypeId: null == activityTypeId ? _self.activityTypeId : activityTypeId // ignore: cast_nullable_to_non_nullable
as int,dateDeadline: null == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,assigneeName: null == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as int?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ScheduledActivityState,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledActivity].
extension ScheduledActivityPatterns on ScheduledActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledActivity value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledActivity value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String summary,  String activityTypeName,  int activityTypeId,  DateTime dateDeadline,  String assigneeName,  int? assigneeId,  ScheduledActivityState state,  bool isOverdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledActivity() when $default != null:
return $default(_that.id,_that.summary,_that.activityTypeName,_that.activityTypeId,_that.dateDeadline,_that.assigneeName,_that.assigneeId,_that.state,_that.isOverdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String summary,  String activityTypeName,  int activityTypeId,  DateTime dateDeadline,  String assigneeName,  int? assigneeId,  ScheduledActivityState state,  bool isOverdue)  $default,) {final _that = this;
switch (_that) {
case _ScheduledActivity():
return $default(_that.id,_that.summary,_that.activityTypeName,_that.activityTypeId,_that.dateDeadline,_that.assigneeName,_that.assigneeId,_that.state,_that.isOverdue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String summary,  String activityTypeName,  int activityTypeId,  DateTime dateDeadline,  String assigneeName,  int? assigneeId,  ScheduledActivityState state,  bool isOverdue)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledActivity() when $default != null:
return $default(_that.id,_that.summary,_that.activityTypeName,_that.activityTypeId,_that.dateDeadline,_that.assigneeName,_that.assigneeId,_that.state,_that.isOverdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledActivity implements ScheduledActivity {
  const _ScheduledActivity({required this.id, required this.summary, required this.activityTypeName, required this.activityTypeId, required this.dateDeadline, required this.assigneeName, this.assigneeId, this.state = ScheduledActivityState.planned, this.isOverdue = false});
  factory _ScheduledActivity.fromJson(Map<String, dynamic> json) => _$ScheduledActivityFromJson(json);

@override final  int id;
@override final  String summary;
@override final  String activityTypeName;
@override final  int activityTypeId;
@override final  DateTime dateDeadline;
@override final  String assigneeName;
@override final  int? assigneeId;
@override@JsonKey() final  ScheduledActivityState state;
@override@JsonKey() final  bool isOverdue;

/// Create a copy of ScheduledActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledActivityCopyWith<_ScheduledActivity> get copyWith => __$ScheduledActivityCopyWithImpl<_ScheduledActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.activityTypeName, activityTypeName) || other.activityTypeName == activityTypeName)&&(identical(other.activityTypeId, activityTypeId) || other.activityTypeId == activityTypeId)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.assigneeName, assigneeName) || other.assigneeName == assigneeName)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summary,activityTypeName,activityTypeId,dateDeadline,assigneeName,assigneeId,state,isOverdue);

@override
String toString() {
  return 'ScheduledActivity(id: $id, summary: $summary, activityTypeName: $activityTypeName, activityTypeId: $activityTypeId, dateDeadline: $dateDeadline, assigneeName: $assigneeName, assigneeId: $assigneeId, state: $state, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class _$ScheduledActivityCopyWith<$Res> implements $ScheduledActivityCopyWith<$Res> {
  factory _$ScheduledActivityCopyWith(_ScheduledActivity value, $Res Function(_ScheduledActivity) _then) = __$ScheduledActivityCopyWithImpl;
@override @useResult
$Res call({
 int id, String summary, String activityTypeName, int activityTypeId, DateTime dateDeadline, String assigneeName, int? assigneeId, ScheduledActivityState state, bool isOverdue
});




}
/// @nodoc
class __$ScheduledActivityCopyWithImpl<$Res>
    implements _$ScheduledActivityCopyWith<$Res> {
  __$ScheduledActivityCopyWithImpl(this._self, this._then);

  final _ScheduledActivity _self;
  final $Res Function(_ScheduledActivity) _then;

/// Create a copy of ScheduledActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? activityTypeName = null,Object? activityTypeId = null,Object? dateDeadline = null,Object? assigneeName = null,Object? assigneeId = freezed,Object? state = null,Object? isOverdue = null,}) {
  return _then(_ScheduledActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,activityTypeName: null == activityTypeName ? _self.activityTypeName : activityTypeName // ignore: cast_nullable_to_non_nullable
as String,activityTypeId: null == activityTypeId ? _self.activityTypeId : activityTypeId // ignore: cast_nullable_to_non_nullable
as int,dateDeadline: null == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,assigneeName: null == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as int?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ScheduledActivityState,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
