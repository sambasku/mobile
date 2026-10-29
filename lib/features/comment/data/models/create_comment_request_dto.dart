import 'package:freezed_annotation/freezed_annotation.dart';

import 'comment_image_dto.dart';

part 'create_comment_request_dto.freezed.dart';
part 'create_comment_request_dto.g.dart';

/// Body POST /api/v1/words/:wordId/comments - teks dan/atau satu foto staging.
@freezed
abstract class CreateCommentRequestDto with _$CreateCommentRequestDto {
  const factory CreateCommentRequestDto({
    @Default('') String body,
    CreateCommentImageInputDto? image,
  }) = _CreateCommentRequestDto;

  factory CreateCommentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestDtoFromJson(json);
}