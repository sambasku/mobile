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
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_verifier') @Default(false) bool isVerifier,
    String? body,
    @JsonKey(name: 'audio_url') String? audioUrl,
    @JsonKey(name: 'audio_mime_type') String? audioMimeType,
    @JsonKey(name: 'audio_duration_ms') int? audioDurationMs,
    @JsonKey(name: 'created_at') String? createdAt,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    String? status,
  }) = _CommentDto;

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);
}
