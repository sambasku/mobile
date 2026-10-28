import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../entities/comment_edit_history.dart';
import '../entities/comment_page.dart';
import '../entities/word_comment.dart';
import '../failures/comment_failure.dart';

/// Interface repository komentar (09-api-comment.md). Semua method
/// mengembalikan `Either`, failure = [CommentFailure].
abstract interface class CommentRepository {
  /// Komentar published pada kata (terbaru dulu), cursor-based.
  Future<Either<CommentFailure, CommentPage>> listByWord({
    required String wordId,
    int limit = 20,
    String? cursor,
  });

  /// Tulis komentar (login) - langsung `published` (post-moderation).
  Future<Either<CommentFailure, WordComment>> create({
    required String wordId,
    required String body,
  });

  /// Komentar suara (login) - multipart; caption opsional.
  Future<Either<CommentFailure, WordComment>> createAudio({
    required String wordId,
    required File audioFile,
    required int durationMs,
    String? body,
  });

  /// Soft-delete komentar sendiri (atau oleh admin/root/reviewer).
  Future<Either<CommentFailure, void>> delete(String commentId);

  /// Sunting komentar sendiri (published).
  Future<Either<CommentFailure, WordComment>> update({
    required String commentId,
    required String body,
  });

  Future<Either<CommentFailure, CommentEditHistory>> editHistory(
    String commentId,
  );
}