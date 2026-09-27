import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/comment_page.dart';
import '../../domain/entities/word_comment.dart';
import '../../domain/failures/comment_failure.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';
import '../models/comment_dto.dart';
import '../models/create_comment_request_dto.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remoteDatasource);

  final CommentRemoteDatasource _remoteDatasource;

  @override
  Future<Either<CommentFailure, CommentPage>> listByWord({
    required String wordId,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDatasource.listByWord(
        wordId,
        {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      if (response.success == false) {
        return Either.left(
          CommentFailure(
            response.message ?? 'Gagal memuat komentar',
            errorCode: response.errorCode,
          ),
        );
      }

      final items = response.data ?? const <CommentDto>[];
      final meta = response.meta;
      return Either.right(
        CommentPage(
          items: items.map(_toEntity).toList(growable: false),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, fallback: 'Gagal memuat komentar'));
    } catch (error) {
      return Either.left(CommentFailure(error.toString()));
    }
  }

  @override
  Future<Either<CommentFailure, WordComment>> create({
    required String wordId,
    required String body,
  }) async {
    try {
      final response = await _remoteDatasource.create(
        wordId,
        CreateCommentRequestDto(body: body),
      );

      if (response.success == false || response.data == null) {
        return Either.left(
          CommentFailure(
            response.message ?? 'Gagal mengirim komentar',
            errorCode: response.errorCode,
          ),
        );
      }

      return Either.right(_toEntity(response.data!));
    } on DioException catch (error) {
      return Either.left(_mapDio(error, fallback: 'Gagal mengirim komentar'));
    } catch (error) {
      return Either.left(CommentFailure(error.toString()));
    }
  }

  @override
  Future<Either<CommentFailure, void>> delete(String commentId) async {
    try {
      final response = await _remoteDatasource.delete(commentId);

      if (response.success == false) {
        return Either.left(
          CommentFailure(
            response.message ?? 'Gagal menghapus komentar',
            errorCode: response.errorCode,
          ),
        );
      }
      return Either.right(null);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, fallback: 'Gagal menghapus komentar'));
    } catch (error) {
      return Either.left(CommentFailure(error.toString()));
    }
  }

  WordComment _toEntity(CommentDto dto) => WordComment(
        id: dto.id,
        wordId: dto.wordId,
        userId: dto.userId,
        username: dto.username,
        displayName: dto.displayName,
        body: dto.body,
        createdAt: dto.createdAt,
        status: dto.status,
        upvotes: dto.upvotes,
        downvotes: dto.downvotes,
      );

  CommentFailure _mapDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        final proper = switch (code) {
          'WORD_NOT_FOUND' => 'Kata tidak ditemukan',
          'COMMENT_NOT_FOUND' => 'Komentar tidak ditemukan',
          'FORBIDDEN' => 'Kamu tidak bisa menghapus komentar ini',
          _ => message,
        };
        return CommentFailure(proper, errorCode: code);
      }
      return CommentFailure(_fallbackForStatus(error.response?.statusCode, code),
          errorCode: code);
    }
    return CommentFailure(_fallbackForStatus(error.response?.statusCode, null));
  }

  String _fallbackForStatus(int? statusCode, String? errorCode) {
    if (statusCode == 429 || errorCode == 'RATE_LIMITED') {
      return 'Terlalu banyak komentar. Coba lagi nanti.';
    }
    if (statusCode == 401) {
      return 'Sesi berakhir, silakan masuk kembali';
    }
    if (statusCode == 403) {
      return 'Kamu tidak bisa menghapus komentar ini';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang gangguan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}