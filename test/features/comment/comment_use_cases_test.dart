import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/comment/domain/entities/comment_page.dart';
import 'package:sambasku_mobile/features/comment/domain/entities/word_comment.dart';
import 'package:sambasku_mobile/features/comment/domain/failures/comment_failure.dart';
import 'package:sambasku_mobile/features/comment/domain/repositories/comment_repository.dart';
import 'package:sambasku_mobile/features/comment/domain/usecases/create_comment_use_case.dart';
import 'package:sambasku_mobile/features/comment/domain/usecases/delete_comment_use_case.dart';
import 'package:sambasku_mobile/features/comment/domain/usecases/list_word_comments_use_case.dart';

/// Use case komentar: create mem-trim body; list/delete meneruskan
/// parameter ke repository apa adanya; failure selalu diteruskan.
class _FakeCommentRepository implements CommentRepository {
  _FakeCommentRepository(this.result);

  final Either<CommentFailure, CommentPage> result;

  String? receivedWordId;
  int? receivedLimit;
  String? receivedCursor;
  String? receivedBody;
  String? receivedCommentId;

  Either<CommentFailure, WordComment> createResult =
      Either.left(const CommentFailure('default'));
  Either<CommentFailure, void> deleteResult =
      Either.left(const CommentFailure('default'));

  @override
  Future<Either<CommentFailure, CommentPage>> listByWord({
    required String wordId,
    int limit = 20,
    String? cursor,
  }) async {
    receivedWordId = wordId;
    receivedLimit = limit;
    receivedCursor = cursor;
    return result;
  }

  @override
  Future<Either<CommentFailure, WordComment>> create({
    required String wordId,
    required String body,
  }) async {
    receivedWordId = wordId;
    receivedBody = body;
    return createResult;
  }

  @override
  Future<Either<CommentFailure, WordComment>> createAudio({
    required String wordId,
    required File audioFile,
    required int durationMs,
    String? body,
  }) async => Either.left(const CommentFailure('tidak dipakai'));

  @override
  Future<Either<CommentFailure, void>> delete(String commentId) async {
    receivedCommentId = commentId;
    return deleteResult;
  }
}

void main() {
  const page = CommentPage(items: [
    WordComment(
      id: 'c1',
      wordId: 'w1',
      userId: 'u1',
      username: 'kontributor',
      body: 'halo',
      upvotes: 3,
    ),
  ]);

  test('ListWordCommentsUseCase - parameter diteruskan, Either utuh', () async {
    final repo = _FakeCommentRepository(Either.right(page));
    final usecase = ListWordCommentsUseCase(repo);

    final r = await usecase(wordId: 'w1', limit: 20, cursor: 'abc');

    expect(repo.receivedWordId, 'w1');
    expect(repo.receivedLimit, 20);
    expect(repo.receivedCursor, 'abc');
    expect(r.getRight().toNullable()?.items.single.body, 'halo');
  });

  test('ListWordCommentsUseCase - failure diteruskan', () async {
    final failure = const CommentFailure('Gagal memuat komentar');
    final repo = _FakeCommentRepository(Either.left(failure));
    final usecase = ListWordCommentsUseCase(repo);

    final r = await usecase(wordId: 'w1');
    expect(r.getLeft().toNullable()?.message, 'Gagal memuat komentar');
  });

  test('CreateCommentUseCase - body di-trim', () async {
    final repo = _FakeCommentRepository(Either.right(page));
    repo.createResult = Either.right(
      const WordComment(
        id: 'c2',
        wordId: 'w1',
        userId: 'u1',
        body: 'komentar baru',
        status: 'pending_review',
      ),
    );
    final usecase = CreateCommentUseCase(repo);

    final r = await usecase(wordId: 'w1', body: '  komentar baru  ');

    expect(repo.receivedBody, 'komentar baru');
    expect(r.getRight().toNullable()?.status, 'pending_review');
  });

  test('CreateCommentUseCase - failure diteruskan', () async {
    final repo = _FakeCommentRepository(Either.right(page));
    repo.createResult = Either.left(
      const CommentFailure('Terlalu banyak komentar', errorCode: 'RATE_LIMITED'),
    );
    final usecase = CreateCommentUseCase(repo);

    final r = await usecase(wordId: 'w1', body: 'halo');
    expect(r.getLeft().toNullable()?.errorCode, 'RATE_LIMITED');
  });

  test('DeleteCommentUseCase - id diteruskan, sukses = null', () async {
    final repo = _FakeCommentRepository(Either.right(page));
    repo.deleteResult = Either.right(null);
    final usecase = DeleteCommentUseCase(repo);

    final r = await usecase('c1');

    expect(repo.receivedCommentId, 'c1');
    // void tidak bisa di-baca nilainya; assert via jenis Either.
    expect(r, isA<Right<CommentFailure, void>>());
  });
}