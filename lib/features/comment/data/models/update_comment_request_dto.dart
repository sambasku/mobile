import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_comment_request_dto.freezed.dart';
part 'update_comment_request_dto.g.dart';

@freezed
abstract class UpdateCommentRequestDto with _$UpdateCommentRequestDto {
  const factory UpdateCommentRequestDto({required String body}) =
      _UpdateCommentRequestDto;

  factory UpdateCommentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentRequestDtoFromJson(json);
}
