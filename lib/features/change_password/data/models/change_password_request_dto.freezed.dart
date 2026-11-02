// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangePasswordRequestDto {

@JsonKey(name: 'old_password') String get oldPassword;@JsonKey(name: 'new_password') String get newPassword;@JsonKey(name: 'confirm_password') String get confirmPassword;
/// Create a copy of ChangePasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordRequestDtoCopyWith<ChangePasswordRequestDto> get copyWith => _$ChangePasswordRequestDtoCopyWithImpl<ChangePasswordRequestDto>(this as ChangePasswordRequestDto, _$identity);

  /// Serializes this ChangePasswordRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangePasswordRequestDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordRequestDto&&(identical(other.oldPassword, _this.oldPassword) || other.oldPassword == _this.oldPassword)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword)&&(identical(other.confirmPassword, _this.confirmPassword) || other.confirmPassword == _this.confirmPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangePasswordRequestDto;
  return Object.hash(runtimeType,_this.oldPassword,_this.newPassword,_this.confirmPassword);
}

@override
String toString() {
  final _this = this as ChangePasswordRequestDto;
  return 'ChangePasswordRequestDto(oldPassword: ${_this.oldPassword}, newPassword: ${_this.newPassword}, confirmPassword: ${_this.confirmPassword})';
}


}

/// @nodoc
abstract mixin class $ChangePasswordRequestDtoCopyWith<$Res>  {
  factory $ChangePasswordRequestDtoCopyWith(ChangePasswordRequestDto value, $Res Function(ChangePasswordRequestDto) _then) = _$ChangePasswordRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'old_password') String oldPassword,@JsonKey(name: 'new_password') String newPassword,@JsonKey(name: 'confirm_password') String confirmPassword
});




}
/// @nodoc
class _$ChangePasswordRequestDtoCopyWithImpl<$Res>
    implements $ChangePasswordRequestDtoCopyWith<$Res> {
  _$ChangePasswordRequestDtoCopyWithImpl(this._self, this._then);

  final ChangePasswordRequestDto _self;
  final $Res Function(ChangePasswordRequestDto) _then;

/// Create a copy of ChangePasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oldPassword = null,Object? newPassword = null,Object? confirmPassword = null,}) {
  return _then(ChangePasswordRequestDto(
oldPassword: null == oldPassword ? _self.oldPassword : oldPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangePasswordRequestDto].
extension ChangePasswordRequestDtoPatterns on ChangePasswordRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'old_password')  String oldPassword, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordRequestDto() when $default != null:
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'old_password')  String oldPassword, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordRequestDto():
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'old_password')  String oldPassword, @JsonKey(name: 'new_password')  String newPassword, @JsonKey(name: 'confirm_password')  String confirmPassword)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordRequestDto() when $default != null:
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangePasswordRequestDto implements ChangePasswordRequestDto {
  const _ChangePasswordRequestDto({@JsonKey(name: 'old_password') required this.oldPassword, @JsonKey(name: 'new_password') required this.newPassword, @JsonKey(name: 'confirm_password') required this.confirmPassword});
  factory _ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestDtoFromJson(json);

@override@JsonKey(name: 'old_password') final  String oldPassword;
@override@JsonKey(name: 'new_password') final  String newPassword;
@override@JsonKey(name: 'confirm_password') final  String confirmPassword;

/// Create a copy of ChangePasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordRequestDtoCopyWith<_ChangePasswordRequestDto> get copyWith => __$ChangePasswordRequestDtoCopyWithImpl<_ChangePasswordRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangePasswordRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordRequestDto&&(identical(other.oldPassword, oldPassword) || other.oldPassword == oldPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,oldPassword,newPassword,confirmPassword);
}

@override
String toString() {
    return 'ChangePasswordRequestDto(oldPassword: $oldPassword, newPassword: $newPassword, confirmPassword: $confirmPassword)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordRequestDtoCopyWith<$Res> implements $ChangePasswordRequestDtoCopyWith<$Res> {
  factory _$ChangePasswordRequestDtoCopyWith(_ChangePasswordRequestDto value, $Res Function(_ChangePasswordRequestDto) _then) = __$ChangePasswordRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'old_password') String oldPassword,@JsonKey(name: 'new_password') String newPassword,@JsonKey(name: 'confirm_password') String confirmPassword
});




}
/// @nodoc
class __$ChangePasswordRequestDtoCopyWithImpl<$Res>
    implements _$ChangePasswordRequestDtoCopyWith<$Res> {
  __$ChangePasswordRequestDtoCopyWithImpl(this._self, this._then);

  final _ChangePasswordRequestDto _self;
  final $Res Function(_ChangePasswordRequestDto) _then;

/// Create a copy of ChangePasswordRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oldPassword = null,Object? newPassword = null,Object? confirmPassword = null,}) {
  return _then(_ChangePasswordRequestDto(
oldPassword: null == oldPassword ? _self.oldPassword : oldPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
