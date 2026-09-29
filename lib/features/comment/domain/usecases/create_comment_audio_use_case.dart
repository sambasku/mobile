import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../entities/word_comment.dart';
import '../failures/comment_failure.dart';
import '../repositories/comment_repository.dart';

/// Komentar suara (login). Caption teks opsional.
class CreateCommentAudioUseCase {
  const CreateCommentAudioUseCase(this._repository);

  final CommentRepository _repository;

  Future<Either<CommentFailure, WordComment>> call({
    required String wordId,
    required File audioFile,
    required int durationMs,
    String? body,
  }) =>
      _repository.createAudio(
        wordId: wordId,
        audioFile: audioFile,
        durationMs: durationMs,
        body: body?.trim(),
      );
}
