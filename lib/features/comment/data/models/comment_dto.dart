import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_dto.freezed.dart';
part 'comment_dto.g.dart';

/// Satu komentar dari list (vote counts) ATAU response create.
/// [body] nullable saat taken_down / deleted_by_author.
@freezed
abstract class CommentDto with _$CommentDto {
  const factory CommentDto({
    required String id,
    @JsonKey(name: 'word_id') required String wordId,
    @JsonKey(name: 'user_id') required String userId,
    String? username,
    @JsonKey(name: 'display_name') String? displayName,
    String? body,
    @JsonKey(name: 'created_at') String? createdAt,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    String? status,
  }) = _CommentDto;

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);
}
