import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/ulid.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/providers/dictionary_domain_providers.dart';

part 'word_detail_providers.g.dart';

/// Load detail kata; [wordIdOrLemma] boleh ULID atau lemma (deep link web).
@Riverpod(keepAlive: true)
Future<WordDetail> wordDetail(Ref ref, String wordIdOrLemma) async {
  final key = wordIdOrLemma.trim();
  final result = looksLikeUlid(key)
      ? await ref.watch(getWordByIdUseCaseProvider)(key)
      : await ref.watch(getWordByLemmaUseCaseProvider)(key);
  return result.match((failure) => throw failure, (detail) => detail);
}

typedef WordDetailQuery = ({
  String id,
  String? meaningId,
  bool includeUnverified,
});

/// Detail dengan makna menunggu (Periksa Kata / feed usulan lemma-makna).
final wordDetailCommunityProvider =
    FutureProvider.autoDispose.family<WordDetail, WordDetailQuery>((
  ref,
  args,
) async {
  final key = args.id.trim();
  final meaningId = args.meaningId?.trim();
  final focus = (meaningId != null && meaningId.isNotEmpty) ? meaningId : null;
  final result = looksLikeUlid(key)
      ? await ref.watch(getWordByIdUseCaseProvider)(
          key,
          focusMeaningId: focus,
          includeUnverified: args.includeUnverified,
        )
      : await ref.watch(getWordByLemmaUseCaseProvider)(
          key,
          focusMeaningId: focus,
          includeUnverified: args.includeUnverified,
        );
  return result.match((failure) => throw failure, (detail) => detail);
});
