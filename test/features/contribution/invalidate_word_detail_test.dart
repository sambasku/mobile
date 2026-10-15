import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/cache/cache_key.dart';
import 'package:sambasku_mobile/core/cache/cache_providers.dart';
import 'package:sambasku_mobile/core/cache/response_cache_store.dart';
import 'package:sambasku_mobile/features/contribution/presentation/utils/invalidate_word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_detail_providers.dart';

class _Store extends Fake implements ResponseCacheStore {
  final deleted = <String>{};

  @override
  Future<void> delete(String key) async => deleted.add(key);
}

/// Issue #159: L1 harus terhapus SEBELUM provider refetch, kalau tidak
/// refetch membaca entri L1 basi dan detail tidak menampilkan data baru.
void main() {
  testWidgets('L1 terhapus sebelum wordDetailProvider refetch', (tester) async {
    const wordId = '01JWORD0000000000000000000';
    const lemma = 'makatn';
    final byId = buildCacheKey(method: 'GET', path: '/api/v1/words/$wordId');
    final byLemma = buildCacheKey(
      method: 'GET',
      path: '/api/v1/words/lemma/$lemma',
    );
    final store = _Store();
    final l1DeletedAtBuild = <bool>[];

    const detail = WordDetail(
      id: wordId,
      lemma: lemma,
      languageId: 'lang-sbs',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      isCorrected: false,
    );
    Future<WordDetail> build(Ref ref) async {
      l1DeletedAtBuild.add(store.deleted.contains(byId));
      return detail;
    }

    final container = ProviderContainer(
      overrides: [
        responseCacheStoreProvider.overrideWithValue(store),
        wordDetailProvider(wordId).overrideWith(build),
        wordDetailProvider(lemma).overrideWith(build),
      ],
    );
    addTearDown(container.dispose);

    late WidgetRef ref;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, r, _) {
            ref = r;
            return const SizedBox();
          },
        ),
      ),
    );

    await container.read(wordDetailProvider(wordId).future);
    expect(l1DeletedAtBuild, [false]);

    await invalidateWordDetailCaches(ref, wordId, lemma);
    expect(store.deleted, {byId, byLemma});

    await container.read(wordDetailProvider(wordId).future);
    expect(l1DeletedAtBuild, [false, true]);
  });
}
