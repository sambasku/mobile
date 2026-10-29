import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_image_dto.freezed.dart';
part 'comment_image_dto.g.dart';

@freezed
abstract class CommentImageDto with _$CommentImageDto {
  const factory CommentImageDto({
    required String status,
    @JsonKey(name: 'public_url') String? publicUrl,
    @JsonKey(name: 'content_warnings')
    @Default(<String>[])
    List<String> contentWarnings,
  }) = _CommentImageDto;

  factory CommentImageDto.fromJson(Map<String, dynamic> json) =>
      _$CommentImageDtoFromJson(json);
}

@freezed
abstract class CreateCommentImageInputDto with _$CreateCommentImageInputDto {
  const factory CreateCommentImageInputDto({
    required String url,
    @JsonKey(name: 'provider_file_id') required String providerFileId,
  }) = _CreateCommentImageInputDto;

  factory CreateCommentImageInputDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentImageInputDtoFromJson(json);
}
