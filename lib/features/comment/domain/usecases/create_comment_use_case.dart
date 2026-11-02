import 'package:fpdart/fpdart.dart' show Either, Left;

import '../../../../core/i18n/l10n.dart';
import '../entities/comment_image.dart';
import '../entities/word_comment.dart';
import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

/// Tulis komentar (login). Body di-trim; minimal 1 karakter (validasi
/// final di backend: VALIDATION_ERROR kalau kosong).
class CreateCommentUseCase {
  const CreateCommentUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, WordComment>> call({
    required String wordId,
    required String body,
    CommentImageStaging? image,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty && image == null) {
      return Future.value(
        Left(CommentFailure(l10n.commentBodyOrPhotoRequired)),
      );
    }
    return _repository.create(
      wordId: wordId,
      body: trimmed,
      image: image,
    );
  }
}