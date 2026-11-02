// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_comment_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateCommentRequestDto {

 String get body;
/// Create a copy of UpdateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCommentRequestDtoCopyWith<UpdateCommentRequestDto> get copyWith => _$UpdateCommentRequestDtoCopyWithImpl<UpdateCommentRequestDto>(this as UpdateCommentRequestDto, _$identity);

  /// Serializes this UpdateCommentRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateCommentRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCommentRequestDto&&(identical(other.body, _this.body) || other.body == _this.body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateCommentRequestDto;
  return Object.hash(runtimeType,_this.body);
}

@override
String toString() {
  final _this = this as UpdateCommentRequestDto;
  return 'UpdateCommentRequestDto(body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $UpdateCommentRequestDtoCopyWith<$Res>  {
  factory $UpdateCommentRequestDtoCopyWith(UpdateCommentRequestDto value, $Res Function(UpdateCommentRequestDto) _then) = _$UpdateCommentRequestDtoCopyWithImpl;
@useResult
$Res call({
 String body
});




}
/// @nodoc
class _$UpdateCommentRequestDtoCopyWithImpl<$Res>
    implements $UpdateCommentRequestDtoCopyWith<$Res> {
  _$UpdateCommentRequestDtoCopyWithImpl(this._self, this._then);

  final UpdateCommentRequestDto _self;
  final $Res Function(UpdateCommentRequestDto) _then;

/// Create a copy of UpdateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? body = null,}) {
  return _then(UpdateCommentRequestDto(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCommentRequestDto].
extension UpdateCommentRequestDtoPatterns on UpdateCommentRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCommentRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCommentRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCommentRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCommentRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCommentRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCommentRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCommentRequestDto() when $default != null:
return $default(_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String body)  $default,) {final _that = this;
switch (_that) {
case _UpdateCommentRequestDto():
return $default(_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String body)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCommentRequestDto() when $default != null:
return $default(_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCommentRequestDto implements UpdateCommentRequestDto {
  const _UpdateCommentRequestDto({required this.body});
  factory _UpdateCommentRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateCommentRequestDtoFromJson(json);

@override final  String body;

/// Create a copy of UpdateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCommentRequestDtoCopyWith<_UpdateCommentRequestDto> get copyWith => __$UpdateCommentRequestDtoCopyWithImpl<_UpdateCommentRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCommentRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCommentRequestDto&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,body);
}

@override
String toString() {
    return 'UpdateCommentRequestDto(body: $body)';
}


}

/// @nodoc
abstract mixin class _$UpdateCommentRequestDtoCopyWith<$Res> implements $UpdateCommentRequestDtoCopyWith<$Res> {
  factory _$UpdateCommentRequestDtoCopyWith(_UpdateCommentRequestDto value, $Res Function(_UpdateCommentRequestDto) _then) = __$UpdateCommentRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String body
});




}
/// @nodoc
class __$UpdateCommentRequestDtoCopyWithImpl<$Res>
    implements _$UpdateCommentRequestDtoCopyWith<$Res> {
  __$UpdateCommentRequestDtoCopyWithImpl(this._self, this._then);

  final _UpdateCommentRequestDto _self;
  final $Res Function(_UpdateCommentRequestDto) _then;

/// Create a copy of UpdateCommentRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? body = null,}) {
  return _then(_UpdateCommentRequestDto(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
