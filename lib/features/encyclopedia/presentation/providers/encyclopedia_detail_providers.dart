import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';

final encyclopediaArticleProvider = FutureProvider.autoDispose
    .family<EncyclopediaArticle?, String>((ref, slug) async {
      final repo = ref.watch(encyclopediaRepositoryProvider);
      final resp = await repo.getArticle(slug);
      return resp.data;
    });

final encyclopediaCommentsProvider = FutureProvider.autoDispose
    .family<List<ArticleComment>, String>((ref, articleId) async {
      final repo = ref.watch(encyclopediaRepositoryProvider);
      final resp = await repo.getComments(articleId, {'limit': 50});
      return resp.data?.items ?? [];
    });
