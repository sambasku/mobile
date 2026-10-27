import '../../../l10n/app_localizations.dart';
import '../domain/entities/my_submission.dart';

/// Label jenis usulan. Domain hanya menyimpan nilai wire.
String mySubmissionKindLabel(AppLocalizations l10n, String entityType) =>
    switch (entityType) {
      'meaning' => l10n.mySubmissionKindMeaning,
      'pronunciation' => l10n.mySubmissionKindPronunciation,
      'word_image' => l10n.mySubmissionKindImage,
      'word_audio' => l10n.mySubmissionKindAudio,
      'example' => l10n.mySubmissionKindExample,
      'word_suggestion' => l10n.mySubmissionKindChange,
      _ => l10n.mySubmissionKindNewWord,
    };

/// Label status usulan. Domain hanya menyimpan nilai wire.
String mySubmissionStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'approved' => l10n.reviewStatusApproved,
      'rejected' => l10n.reviewStatusRejected,
      'corrected' => l10n.reviewStatusCorrected,
      _ => l10n.myContributionPending,
    };

/// Judul tile: lemma, atau label jenis usulan bila lemma kosong.
String mySubmissionTitle(AppLocalizations l10n, MySubmission item) {
  final value = item.lemma?.trim();
  if (value != null && value.isNotEmpty) return value;
  return mySubmissionKindLabel(l10n, item.entityType);
}

/// Cuplikan catatan reviewer untuk tile (maks 60 karakter).
String submissionReviewSnippet(String? reviewComment) {
  final comment = reviewComment?.trim() ?? '';
  if (comment.isEmpty) return '';
  return comment.length > 60 ? '${comment.substring(0, 60)}...' : comment;
}

/// Subtitle tile: jenis · status · tanggal, plus cuplikan catatan reviewer.
String mySubmissionSubtitle(
  AppLocalizations l10n,
  MySubmission item,
  String formattedDate,
) {
  final parts = <String>[
    mySubmissionKindLabel(l10n, item.entityType),
    mySubmissionStatusLabel(l10n, item.status),
    if (formattedDate.isNotEmpty) formattedDate,
  ];
  var text = parts.join(' · ');
  if (item.status == 'rejected') {
    final short = submissionReviewSnippet(item.reviewComment);
    if (short.isNotEmpty) text = '$text · $short';
  }
  return text;
}
