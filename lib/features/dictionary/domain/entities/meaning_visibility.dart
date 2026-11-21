import 'word_detail.dart';

/// Makna yang boleh tampil di detail kamus publik.
///
/// Default: hanya verified.
/// - [focusMeaningId]: makna fokus ikut (Periksa Kata).
/// - [includeUnverified]: semua makna published (feed usulan / lemma baru).
/// - verifikator: semua.
List<WordMeaning> visibleMeaningsForPublicDetail(
  List<WordMeaning> meanings, {
  required bool viewerIsVerifier,
  String? focusMeaningId,
  bool includeUnverified = false,
}) {
  if (viewerIsVerifier || includeUnverified) return meanings;
  final focus = focusMeaningId?.trim();
  if (focus != null && focus.isNotEmpty) {
    return [
      for (final m in meanings)
        if (m.isVerified || m.id == focus) m,
    ];
  }
  return [for (final m in meanings) if (m.isVerified) m];
}
