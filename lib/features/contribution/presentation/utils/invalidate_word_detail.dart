import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';

/// Issue #28: setelah usulan kata terkirim, hapus cache detail kata
/// (Riverpod keepAlive + L1 HTTP) supaya buka lagi tidak lihat data basi.
///
/// Kunci `wordDetailProvider` bisa ULID atau lemma, keduanya di-flush.
/// L1 dihapus di endpoint by-id dan by-lemma.
Future<void> invalidateWordDetailCaches(
  WidgetRef ref,
  String wordId,
  String lemma,
) async {
  if (wordId.isNotEmpty) ref.invalidate(wordDetailProvider(wordId));
  final cleanLemma = lemma.trim();
  if (cleanLemma.isNotEmpty) ref.invalidate(wordDetailProvider(cleanLemma));

  final store = ref.read(responseCacheStoreProvider);
  await Future.wait([
    if (wordId.isNotEmpty)
      store.delete(buildCacheKey(method: 'GET', path: '/api/v1/words/$wordId')),
    if (cleanLemma.isNotEmpty)
      store.delete(
        buildCacheKey(
          method: 'GET',
          path: '/api/v1/words/lemma/${Uri.encodeComponent(cleanLemma)}',
        ),
      ),
  ]);
}
