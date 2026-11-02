import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import 'bulk_submit_word_providers.dart';
import 'lemma_check_providers.dart';

/// Hasil cek satu lemma di tabel massal.
/// [wordId] terisi hanya jika kata sudah ada di kamus.
class BulkLemmaMark {
  const BulkLemmaMark.found(this.wordId) : exists = true;

  const BulkLemmaMark.absent() : exists = false, wordId = null;

  final bool exists;
  final String? wordId;
}

/// Lemma unik (lowercase) yang perlu dicek. Nilai = teks trim untuk request.
/// Lemma pendek dan duplikat (beda kapital) dijatuhkan.
Map<String, String> bulkLemmasToCheck(Iterable<String> rawLemmas) {
  final out = <String, String>{};
  for (final raw in rawLemmas) {
    final trimmed = raw.trim();
    final key = trimmed.toLowerCase();
    if (key.length < kLemmaCheckMinLength) continue;
    out.putIfAbsent(key, () => trimmed);
  }
  return out;
}

/// Cek ketersediaan lemma untuk semua baris massal (issue #181).
/// Satu request per lemma unik, setelah [kLemmaCheckDebounce] sejak
/// ketukan terakhir. UI hanya menampilkan icon bila [BulkLemmaMark.wordId]
/// terisi, tanpa kolom tambahan.
class BulkLemmaCheckNotifier extends Notifier<Map<String, BulkLemmaMark>> {
  Timer? _debounce;
  final Map<String, int> _ticket = {};
  final Set<String> _inflight = {};

  @override
  Map<String, BulkLemmaMark> build() {
    ref.onDispose(() => _debounce?.cancel());
    ref.listen(
      bulkSubmitWordProvider.select(
        (s) => s.rows.map((r) => r.lemma.trim().toLowerCase()).join('\n'),
      ),
      (previous, next) => _schedule(),
    );
    return const {};
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(kLemmaCheckDebounce, _run);
  }

  void _run() {
    final want = bulkLemmasToCheck(
      ref.read(bulkSubmitWordProvider).rows.map((r) => r.lemma),
    );

    for (final key in _inflight.toList()) {
      if (want.containsKey(key)) continue;
      _ticket[key] = (_ticket[key] ?? 0) + 1;
      _inflight.remove(key);
    }

    final kept = {
      for (final entry in state.entries)
        if (want.containsKey(entry.key)) entry.key: entry.value,
    };
    if (kept.length != state.length) state = kept;

    for (final entry in want.entries) {
      final key = entry.key;
      if (state.containsKey(key) || _inflight.contains(key)) continue;
      final ticket = (_ticket[key] ?? 0) + 1;
      _ticket[key] = ticket;
      _inflight.add(key);
      unawaited(_fetch(key, entry.value, ticket));
    }
  }

  Future<void> _fetch(String key, String lemma, int ticket) async {
    try {
      final result = await ref.read(getWordByLemmaUseCaseProvider)(lemma);
      if (!ref.mounted || _ticket[key] != ticket) return;
      final stillThere = bulkLemmasToCheck(
        ref.read(bulkSubmitWordProvider).rows.map((r) => r.lemma),
      ).containsKey(key);
      if (!stillThere) return;
      result.match(
        (failure) {
          if (failure.errorCode != 'WORD_NOT_FOUND') return;
          // Cache negatif supaya edit baris lain tidak mengulang 404.
          state = {...state, key: const BulkLemmaMark.absent()};
        },
        (detail) {
          state = {...state, key: BulkLemmaMark.found(detail.id)};
        },
      );
    } finally {
      if (_ticket[key] == ticket) _inflight.remove(key);
    }
  }
}

final bulkLemmaCheckProvider =
    NotifierProvider<BulkLemmaCheckNotifier, Map<String, BulkLemmaMark>>(
      BulkLemmaCheckNotifier.new,
    );
