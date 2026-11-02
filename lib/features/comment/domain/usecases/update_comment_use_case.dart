import 'package:fpdart/fpdart.dart';

import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';
import '../entities/word_comment.dart';

class UpdateCommentUseCase {
  const UpdateCommentUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, WordComment>> call({
    required String commentId,
    required String body,
  }) =>
      _repository.update(commentId: commentId, body: body);
}
