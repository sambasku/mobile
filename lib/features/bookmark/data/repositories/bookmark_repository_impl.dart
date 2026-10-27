import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/bookmark_item.dart';
import '../../domain/entities/bookmark_page.dart';
import '../../domain/entities/bookmark_status.dart';
import '../../domain/entities/bookmark_word.dart';
import '../../domain/failures/bookmark_failure.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_datasource.dart';
import '../models/bookmark_item_dto.dart';
import '../models/toggle_bookmark_request_dto.dart';
import '../../../../core/i18n/l10n.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl(this._remoteDatasource);

  final BookmarkRemoteDatasource _remoteDatasource;

  @override
  Future<Either<BookmarkFailure, BookmarkStatus>> toggle(String wordId) async {
    try {
      final response = await _remoteDatasource.toggle(
        ToggleBookmarkRequestDto(wordId: wordId),
      );

      if (response.success == false || response.data == null) {
        return Either.left(
          BookmarkFailure(
            response.message ?? l10n.bookmarkToggleFailed,
            errorCode: response.errorCode,
          ),
        );
      }

      final dto = response.data!;
      return Either.right(
        BookmarkStatus(
          wordId: dto.wordId,
          isBookmarked: dto.isBookmarked,
          bookmarkedAt: dto.bookmarkedAt,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(BookmarkFailure(error.toString()));
    }
  }

  @override
  Future<Either<BookmarkFailure, BookmarkPage>> myBookmarks({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDatasource.getMyBookmarks({
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      });

      if (response.success == false) {
        return Either.left(
          BookmarkFailure(
            response.message ?? l10n.bookmarkLoadFailed,
            errorCode: response.errorCode,
          ),
        );
      }

      final meta = response.meta;
      return Either.right(
        BookmarkPage(
          items: (response.data ?? const <BookmarkItemDto>[])
              .map(_mapItem)
              .toList(growable: false),
          nextCursor: meta?['next_cursor'] as String?,
          hasMore: meta?['has_more'] as bool? ?? false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(BookmarkFailure(error.toString()));
    }
  }

  @override
  Future<Either<BookmarkFailure, Map<String, BookmarkStatus>>> statuses(
    List<String> wordIds,
  ) async {
    try {
      final response = await _remoteDatasource.getMyBookmarks({
        'word_ids': wordIds.join(','),
      });

      if (response.success == false) {
        return Either.left(
          BookmarkFailure(
            response.message ?? l10n.bookmarkStatusLoadFailed,
            errorCode: response.errorCode,
          ),
        );
      }

      final result = <String, BookmarkStatus>{};
      for (final dto in response.data ?? const <BookmarkItemDto>[]) {
        result[dto.wordId] = BookmarkStatus(
          wordId: dto.wordId,
          isBookmarked: true,
          bookmarkedAt: dto.bookmarkedAt,
        );
      }
      return Either.right(result);
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(BookmarkFailure(error.toString()));
    }
  }

  BookmarkItem _mapItem(BookmarkItemDto dto) => BookmarkItem(
        wordId: dto.wordId,
        bookmarkedAt: dto.bookmarkedAt,
        word: BookmarkWord(
          id: dto.word.id,
          lemma: dto.word.lemma,
          wordType: dto.word.wordType,
          isVerified: dto.word.isVerified,
          available: dto.word.available,
        ),
      );

  BookmarkFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['error_code'] as String?;
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        final proper = code == 'WORD_NOT_FOUND'
            ? l10n.bookmarkWordGone
            : message;
        return BookmarkFailure(proper, errorCode: code);
      }
      final fallback = _fallbackForStatus(error.response?.statusCode, code);
      return BookmarkFailure(fallback, errorCode: code);
    }
    return BookmarkFailure(_fallbackForStatus(error.response?.statusCode, null));
  }

  String _fallbackForStatus(int? statusCode, String? errorCode) {
    if (statusCode == 429 || errorCode == 'RATE_LIMITED') {
      return l10n.commonRateLimited;
    }
    if (statusCode == 401) {
      return l10n.commonSessionExpired;
    }
    if (statusCode != null && statusCode >= 500) {
      return l10n.commonServerError;
    }
    return l10n.bookmarkLoadFailed;
  }
}
