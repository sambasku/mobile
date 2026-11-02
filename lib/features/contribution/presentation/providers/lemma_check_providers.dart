import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';

part 'lemma_check_providers.g.dart';

/// Debounce cek lemma (issue #170, #182). Lebih santai dari search (400ms)
/// karena hanya indikator non-blocking. Label "memeriksa" ikut jendela ini:
/// tidak nyala di setiap ketukan. Dipakai juga oleh cek massal (issue #181).
const kLemmaCheckDebounce = Duration(milliseconds: 600);

/// Min panjang lemma sebelum dicek - sama ambang search.miss di API.
const kLemmaCheckMinLength = 2;

/// State hasil cek ketersediaan lemma. `exists == null` = belum ada
/// jawaban yang valid untuk lemma saat ini (idle / checking / error jaringan
/// - semuanya diam tanpa indikator).
class LemmaCheckState {
  const LemmaCheckState({
    this.checking = false,
    this.exists,
    this.wordId,
    this.checkedLemma = '',
  });

  final bool checking;
  final bool? exists;
  final String? wordId;

  /// Lemma yang sudah dicek - dipakai supaya UI tidak menampilkan hasil
  /// lemma lama saat user lanjut mengetik.
  final String checkedLemma;
}

/// Cek ketersediaan lemma lewat GET /words/lemma/{lemma} (issue #170).
/// Non-blocking: hasil hanya untuk label, tidak memblokir submit.
@riverpod
class LemmaCheckNotifier extends _$LemmaCheckNotifier {
  Timer? _debounce;
  int _reqId = 0;

  /// Lemma terakhir yang sudah dijadwalkan. Listener controller juga
  /// jalan saat kursor pindah, jadi teks yang sama tidak mengulang cek.
  String _scheduledLemma = '';

  @override
  LemmaCheckState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });
    return const LemmaCheckState();
  }

  /// Dipanggil dari listener TextEditingController lemma.
  void onLemmaChanged(String raw) {
    final lemma = raw.trim();
    if (lemma == _scheduledLemma) return;
    _scheduledLemma = lemma;
    _debounce?.cancel();
    _reqId++;
    if (lemma.length < kLemmaCheckMinLength) {
      state = const LemmaCheckState();
      return;
    }
    // Sembunyikan hasil lemma sebelumnya. Indikator baru nyala di dalam
    // timer, saat request benar-benar dikirim.
    state = const LemmaCheckState();
    _debounce = Timer(kLemmaCheckDebounce, () {
      if (!ref.mounted) return;
      state = const LemmaCheckState(checking: true);
      _check(lemma);
    });
  }

  Future<void> _check(String lemma) async {
    final reqId = ++_reqId;
    final usecase = ref.read(getWordByLemmaUseCaseProvider);
    final result = await usecase(lemma);
    // Response basi: user sudah mengubah lemma sebelum jawaban tiba.
    if (!ref.mounted || reqId != _reqId) return;
    result.match(
      (failure) {
        if (failure.errorCode == 'WORD_NOT_FOUND') {
          state = LemmaCheckState(exists: false, checkedLemma: lemma);
        } else {
          // Error jaringan / server: diam, jangan tampilkan apa pun.
          state = const LemmaCheckState();
        }
      },
      (detail) {
        // Lemma dijawab bisa beda kasus (lower() di server) - anggap match.
        state = LemmaCheckState(
          exists: true,
          wordId: detail.id,
          checkedLemma: lemma,
        );
      },
    );
  }
}
