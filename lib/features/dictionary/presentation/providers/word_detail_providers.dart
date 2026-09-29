import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/ulid.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'word_detail_providers.g.dart';

/// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
/// Error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per kunci tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch
/// Riverpod. Repository juga menulis L1 (`CacheClass.dictionaryDetail`)
/// supaya cold start / kill process masih bisa HIT dalam TTL.
/// Pull-to-refresh: hard miss L1 (`forceRefresh: true`) lalu invalidate.
@Riverpod(keepAlive: true)
Future<WordDetail> wordDetail(Ref ref, String wordIdOrLemma) async {
  final key = wordIdOrLemma.trim();
  final result = looksLikeUlid(key)
      ? await ref.watch(getWordByIdUseCaseProvider)(key)
      : await ref.watch(getWordByLemmaUseCaseProvider)(key);
  return result.match(
    (failure) => throw failure,
    (detail) => detail,
  );
}
