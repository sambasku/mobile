import 'package:dio/dio.dart';

import '../../core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Anchor API komentar UGC (selaras `ugc_comment_lemma_links` di API).
enum UgcCommentLemmaAnchor {
  wordComment('word_comment', '/api/v1/words'),
  placeComment('place_comment', '/api/v1/places'),
  usahaComment('usaha_comment', '/api/v1/usaha'),
  cuisineComment('cuisine_comment', '/api/v1/culinary'),
  eventComment('event_comment', '/api/v1/events'),
  articleComment('article_comment', '/api/v1/encyclopedia');

  const UgcCommentLemmaAnchor(this.wireKind, this.apiPrefix);
  final String wireKind;
  final String apiPrefix;

  String createPath({
    required String hostId,
    required String commentId,
  }) {
    if (this == UgcCommentLemmaAnchor.articleComment) {
      return '$apiPrefix/articles/$hostId/comments/$commentId/lemma-links';
    }
    return '$apiPrefix/$hostId/comments/$commentId/lemma-links';
  }
}

final ugcCommentLemmaClientProvider = Provider<UgcCommentLemmaClient>((ref) {
  return UgcCommentLemmaClient(ref.watch(dioProvider));
});

class UgcCommentLemmaClient {
  UgcCommentLemmaClient(this._dio);

  final Dio _dio;

  Future<void> createLink({
    required UgcCommentLemmaAnchor anchor,
    required String hostId,
    required String commentId,
    required int start,
    required int end,
    required String wordId,
  }) async {
    await _dio.post<void>(
      anchor.createPath(hostId: hostId, commentId: commentId),
      data: {
        'start': start,
        'end': end,
        'word_id': wordId,
      },
    );
  }
}