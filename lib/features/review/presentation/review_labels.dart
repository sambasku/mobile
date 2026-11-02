import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../domain/entities/review_contribution.dart';
import '../domain/entities/word_suggestion_review.dart';

/// Label tipe entity review (domain cuma simpan kode stabil).
String reviewEntityLabel(String entityType, AppLocalizations l10n) =>
    switch (entityType) {
      'word' => l10n.reviewEntityWord,
      'pronunciation' => l10n.reviewEntityPronunciation,
      'word_image' => l10n.reviewEntityWordImage,
      'word_audio' => l10n.reviewEntityWordAudio,
      'example' => l10n.reviewEntityExample,
      'meaning' => l10n.reviewEntityMeaning,
      _ => l10n.reviewEntityOther,
    };

String reviewStatusLabel(String status, AppLocalizations l10n) =>
    switch (status) {
      'pending' => l10n.reviewStatusPending,
      'approved' => l10n.reviewStatusApproved,
      'rejected' => l10n.reviewStatusRejected,
      'corrected' => l10n.reviewStatusCorrected,
      _ => status,
    };

/// Judul baris: lemma, atau label entity bila lemma kosong.
String reviewTitle(ReviewItem item, AppLocalizations l10n) {
  final lemma = item.wordLemma?.trim();
  if (lemma != null && lemma.isNotEmpty) return lemma;
  return reviewEntityLabel(item.entityType, l10n);
}

/// Nama tampilan kontributor; fallback username lalu label netral.
String reviewContributorLabel(ReviewItem item, AppLocalizations l10n) =>
    item.contributorLabel ?? l10n.reviewContributorFallback;

String reviewSuggestionContributorLabel(
  WordSuggestionSummary item,
  AppLocalizations l10n,
) =>
    item.contributorLabel ?? l10n.reviewContributorFallback;

/// Ringkasan isi usulan edit ("lemma, makna (2)").
String reviewSuggestionChangeHint(
  WordSuggestionSummary item,
  AppLocalizations l10n,
) {
  final parts = <String>[
    if (item.summaryLemma?.isNotEmpty == true) l10n.reviewChangeHintLemma,
    if (item.summaryNotes?.isNotEmpty == true) l10n.reviewChangeHintNotes,
    if (item.meaningsCount > 0) l10n.reviewChangeHintMeanings(item.meaningsCount),
    if (item.imagesCount > 0) l10n.reviewChangeHintImages(item.imagesCount),
  ];
  return parts.isEmpty ? l10n.reviewChangeHintFallback : parts.join(', ');
}

/// Filter riwayat verifikasi (value API + label locale aktif).
List<({String? value, String label})> reviewHistoryStatusFilters(
  AppLocalizations l10n,
) =>
    [
      (value: null, label: l10n.reviewStatusAll),
      (value: 'approved', label: l10n.reviewStatusApproved),
      (value: 'rejected', label: l10n.reviewStatusRejected),
      (value: 'corrected', label: l10n.reviewStatusCorrected),
      (value: 'pending', label: l10n.reviewStatusReopened),
    ];

/// Satu baris meta "status · kontributor".
String reviewStatusContributorLine(
  ReviewItem item,
  AppLocalizations l10n,
) =>
    '${reviewStatusLabel(item.status, l10n)} · '
    '${reviewContributorLabel(item, l10n)}';
