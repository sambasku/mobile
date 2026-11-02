// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_account_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeleteAccountMessageDto {

 String get message;
/// Create a copy of DeleteAccountMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteAccountMessageDtoCopyWith<DeleteAccountMessageDto> get copyWith => _$DeleteAccountMessageDtoCopyWithImpl<DeleteAccountMessageDto>(this as DeleteAccountMessageDto, _$identity);

  /// Serializes this DeleteAccountMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeleteAccountMessageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteAccountMessageDto&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeleteAccountMessageDto;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as DeleteAccountMessageDto;
  return 'DeleteAccountMessageDto(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $DeleteAccountMessageDtoCopyWith<$Res>  {
  factory $DeleteAccountMessageDtoCopyWith(DeleteAccountMessageDto value, $Res Function(DeleteAccountMessageDto) _then) = _$DeleteAccountMessageDtoCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DeleteAccountMessageDtoCopyWithImpl<$Res>
    implements $DeleteAccountMessageDtoCopyWith<$Res> {
  _$DeleteAccountMessageDtoCopyWithImpl(this._self, this._then);

  final DeleteAccountMessageDto _self;
  final $Res Function(DeleteAccountMessageDto) _then;

/// Create a copy of DeleteAccountMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(DeleteAccountMessageDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeleteAccountMessageDto].
extension DeleteAccountMessageDtoPatterns on DeleteAccountMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeleteAccountMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteAccountMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeleteAccountMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _DeleteAccountMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeleteAccountMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeleteAccountMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeleteAccountMessageDto() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _DeleteAccountMessageDto():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _DeleteAccountMessageDto() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeleteAccountMessageDto implements DeleteAccountMessageDto {
  const _DeleteAccountMessageDto({required this.message});
  factory _DeleteAccountMessageDto.fromJson(Map<String, dynamic> json) => _$DeleteAccountMessageDtoFromJson(json);

@override final  String message;

/// Create a copy of DeleteAccountMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteAccountMessageDtoCopyWith<_DeleteAccountMessageDto> get copyWith => __$DeleteAccountMessageDtoCopyWithImpl<_DeleteAccountMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteAccountMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountMessageDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'DeleteAccountMessageDto(message: $message)';
}


}

/// @nodoc
abstract mixin class _$DeleteAccountMessageDtoCopyWith<$Res> implements $DeleteAccountMessageDtoCopyWith<$Res> {
  factory _$DeleteAccountMessageDtoCopyWith(_DeleteAccountMessageDto value, $Res Function(_DeleteAccountMessageDto) _then) = __$DeleteAccountMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$DeleteAccountMessageDtoCopyWithImpl<$Res>
    implements _$DeleteAccountMessageDtoCopyWith<$Res> {
  __$DeleteAccountMessageDtoCopyWithImpl(this._self, this._then);

  final _DeleteAccountMessageDto _self;
  final $Res Function(_DeleteAccountMessageDto) _then;

/// Create a copy of DeleteAccountMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_DeleteAccountMessageDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
