import 'package:fpdart/fpdart.dart';

import '../entities/comment_edit_history.dart';
import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

class GetCommentEditHistoryUseCase {
  const GetCommentEditHistoryUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, CommentEditHistory>> call(String commentId) =>
      _repository.editHistory(commentId);
}
