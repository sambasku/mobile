// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_image_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentImageDto {

 String get status;@JsonKey(name: 'public_url') String? get publicUrl;@JsonKey(name: 'content_warnings') List<String> get contentWarnings;
/// Create a copy of CommentImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentImageDtoCopyWith<CommentImageDto> get copyWith => _$CommentImageDtoCopyWithImpl<CommentImageDto>(this as CommentImageDto, _$identity);

  /// Serializes this CommentImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CommentImageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentImageDto&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.publicUrl, _this.publicUrl) || other.publicUrl == _this.publicUrl)&&const DeepCollectionEquality().equals(other.contentWarnings, _this.contentWarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CommentImageDto;
  return Object.hash(runtimeType,_this.status,_this.publicUrl,const DeepCollectionEquality().hash(_this.contentWarnings));
}

@override
String toString() {
  final _this = this as CommentImageDto;
  return 'CommentImageDto(status: ${_this.status}, publicUrl: ${_this.publicUrl}, contentWarnings: ${_this.contentWarnings})';
}


}

/// @nodoc
abstract mixin class $CommentImageDtoCopyWith<$Res>  {
  factory $CommentImageDtoCopyWith(CommentImageDto value, $Res Function(CommentImageDto) _then) = _$CommentImageDtoCopyWithImpl;
@useResult
$Res call({
 String status,@JsonKey(name: 'public_url') String? publicUrl,@JsonKey(name: 'content_warnings') List<String> contentWarnings
});




}
/// @nodoc
class _$CommentImageDtoCopyWithImpl<$Res>
    implements $CommentImageDtoCopyWith<$Res> {
  _$CommentImageDtoCopyWithImpl(this._self, this._then);

  final CommentImageDto _self;
  final $Res Function(CommentImageDto) _then;

/// Create a copy of CommentImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? publicUrl = freezed,Object? contentWarnings = null,}) {
  return _then(CommentImageDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,contentWarnings: null == contentWarnings ? _self.contentWarnings : contentWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentImageDto].
extension CommentImageDtoPatterns on CommentImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentImageDto value)  $default,){
final _that = this;
switch (_that) {
case _CommentImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _CommentImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'public_url')  String? publicUrl, @JsonKey(name: 'content_warnings')  List<String> contentWarnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentImageDto() when $default != null:
return $default(_that.status,_that.publicUrl,_that.contentWarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'public_url')  String? publicUrl, @JsonKey(name: 'content_warnings')  List<String> contentWarnings)  $default,) {final _that = this;
switch (_that) {
case _CommentImageDto():
return $default(_that.status,_that.publicUrl,_that.contentWarnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status, @JsonKey(name: 'public_url')  String? publicUrl, @JsonKey(name: 'content_warnings')  List<String> contentWarnings)?  $default,) {final _that = this;
switch (_that) {
case _CommentImageDto() when $default != null:
return $default(_that.status,_that.publicUrl,_that.contentWarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentImageDto implements CommentImageDto {
  const _CommentImageDto({required this.status, @JsonKey(name: 'public_url') this.publicUrl, @JsonKey(name: 'content_warnings')  List<String> contentWarnings = const <String>[]}): _contentWarnings = contentWarnings;
  factory _CommentImageDto.fromJson(Map<String, dynamic> json) => _$CommentImageDtoFromJson(json);

@override final  String status;
@override@JsonKey(name: 'public_url') final  String? publicUrl;
 final  List<String> _contentWarnings;
@override@JsonKey(name: 'content_warnings') List<String> get contentWarnings {
  if (_contentWarnings is EqualUnmodifiableListView) return _contentWarnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contentWarnings);
}


/// Create a copy of CommentImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentImageDtoCopyWith<_CommentImageDto> get copyWith => __$CommentImageDtoCopyWithImpl<_CommentImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentImageDto&&(identical(other.status, status) || other.status == status)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl)&&const DeepCollectionEquality().equals(other.contentWarnings, _contentWarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,publicUrl,const DeepCollectionEquality().hash(_contentWarnings));
}

@override
String toString() {
    return 'CommentImageDto(status: $status, publicUrl: $publicUrl, contentWarnings: $contentWarnings)';
}


}

/// @nodoc
abstract mixin class _$CommentImageDtoCopyWith<$Res> implements $CommentImageDtoCopyWith<$Res> {
  factory _$CommentImageDtoCopyWith(_CommentImageDto value, $Res Function(_CommentImageDto) _then) = __$CommentImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String status,@JsonKey(name: 'public_url') String? publicUrl,@JsonKey(name: 'content_warnings') List<String> contentWarnings
});




}
/// @nodoc
class __$CommentImageDtoCopyWithImpl<$Res>
    implements _$CommentImageDtoCopyWith<$Res> {
  __$CommentImageDtoCopyWithImpl(this._self, this._then);

  final _CommentImageDto _self;
  final $Res Function(_CommentImageDto) _then;

/// Create a copy of CommentImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? publicUrl = freezed,Object? contentWarnings = null,}) {
  return _then(_CommentImageDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,contentWarnings: null == contentWarnings ? _self._contentWarnings : contentWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CreateCommentImageInputDto {

 String get url;@JsonKey(name: 'provider_file_id') String get providerFileId;
/// Create a copy of CreateCommentImageInputDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCommentImageInputDtoCopyWith<CreateCommentImageInputDto> get copyWith => _$CreateCommentImageInputDtoCopyWithImpl<CreateCommentImageInputDto>(this as CreateCommentImageInputDto, _$identity);

  /// Serializes this CreateCommentImageInputDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateCommentImageInputDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCommentImageInputDto&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.providerFileId, _this.providerFileId) || other.providerFileId == _this.providerFileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateCommentImageInputDto;
  return Object.hash(runtimeType,_this.url,_this.providerFileId);
}

@override
String toString() {
  final _this = this as CreateCommentImageInputDto;
  return 'CreateCommentImageInputDto(url: ${_this.url}, providerFileId: ${_this.providerFileId})';
}


}

/// @nodoc
abstract mixin class $CreateCommentImageInputDtoCopyWith<$Res>  {
  factory $CreateCommentImageInputDtoCopyWith(CreateCommentImageInputDto value, $Res Function(CreateCommentImageInputDto) _then) = _$CreateCommentImageInputDtoCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId
});




}
/// @nodoc
class _$CreateCommentImageInputDtoCopyWithImpl<$Res>
    implements $CreateCommentImageInputDtoCopyWith<$Res> {
  _$CreateCommentImageInputDtoCopyWithImpl(this._self, this._then);

  final CreateCommentImageInputDto _self;
  final $Res Function(CreateCommentImageInputDto) _then;

/// Create a copy of CreateCommentImageInputDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? providerFileId = null,}) {
  return _then(CreateCommentImageInputDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCommentImageInputDto].
extension CreateCommentImageInputDtoPatterns on CreateCommentImageInputDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCommentImageInputDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCommentImageInputDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCommentImageInputDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateCommentImageInputDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCommentImageInputDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCommentImageInputDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCommentImageInputDto() when $default != null:
return $default(_that.url,_that.providerFileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)  $default,) {final _that = this;
switch (_that) {
case _CreateCommentImageInputDto():
return $default(_that.url,_that.providerFileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'provider_file_id')  String providerFileId)?  $default,) {final _that = this;
switch (_that) {
case _CreateCommentImageInputDto() when $default != null:
return $default(_that.url,_that.providerFileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCommentImageInputDto implements CreateCommentImageInputDto {
  const _CreateCommentImageInputDto({required this.url, @JsonKey(name: 'provider_file_id') required this.providerFileId});
  factory _CreateCommentImageInputDto.fromJson(Map<String, dynamic> json) => _$CreateCommentImageInputDtoFromJson(json);

@override final  String url;
@override@JsonKey(name: 'provider_file_id') final  String providerFileId;

/// Create a copy of CreateCommentImageInputDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCommentImageInputDtoCopyWith<_CreateCommentImageInputDto> get copyWith => __$CreateCommentImageInputDtoCopyWithImpl<_CreateCommentImageInputDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCommentImageInputDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCommentImageInputDto&&(identical(other.url, url) || other.url == url)&&(identical(other.providerFileId, providerFileId) || other.providerFileId == providerFileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,providerFileId);
}

@override
String toString() {
    return 'CreateCommentImageInputDto(url: $url, providerFileId: $providerFileId)';
}


}

/// @nodoc
abstract mixin class _$CreateCommentImageInputDtoCopyWith<$Res> implements $CreateCommentImageInputDtoCopyWith<$Res> {
  factory _$CreateCommentImageInputDtoCopyWith(_CreateCommentImageInputDto value, $Res Function(_CreateCommentImageInputDto) _then) = __$CreateCommentImageInputDtoCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'provider_file_id') String providerFileId
});




}
/// @nodoc
class __$CreateCommentImageInputDtoCopyWithImpl<$Res>
    implements _$CreateCommentImageInputDtoCopyWith<$Res> {
  __$CreateCommentImageInputDtoCopyWithImpl(this._self, this._then);

  final _CreateCommentImageInputDto _self;
  final $Res Function(_CreateCommentImageInputDto) _then;

/// Create a copy of CreateCommentImageInputDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? providerFileId = null,}) {
  return _then(_CreateCommentImageInputDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,providerFileId: null == providerFileId ? _self.providerFileId : providerFileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
