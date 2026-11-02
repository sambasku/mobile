import '../../../l10n/app_localizations.dart';
import '../domain/entities/my_comment_item.dart';

/// Label status komentar. Domain hanya menyimpan nilai wire.
String commentStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'published' => l10n.myCommentsFilterPublished,
      'taken_down' => l10n.myCommentsFilterTakenDown,
      'deleted_by_author' => l10n.myCommentsFilterDeleted,
      _ => status,
    };

/// Nilai wire filter status komentar; label diambil dari l10n.
const commentStatusFilters = <String?>[
  null,
  'published',
  'taken_down',
  'deleted_by_author',
];

String commentStatusFilterLabel(AppLocalizations l10n, String? status) =>
    status == null
        ? l10n.myCommentsFilterAll
        : commentStatusLabel(l10n, status);

/// Judul tile: lemma kata, atau penanda kata tidak tersedia.
String myCommentTitle(AppLocalizations l10n, MyCommentItem item) =>
    item.canOpen ? item.wordLemma! : l10n.myCommentsWordGone;

/// Subtitle tile: status · cuplikan · tanggal.
String myCommentSubtitle(
  AppLocalizations l10n,
  MyCommentItem item,
  String date,
) {
  final snippet = item.body.length <= 80
      ? item.body
      : '${item.body.substring(0, 80)}…';
  return '${commentStatusLabel(l10n, item.status)} · $snippet · $date';
}
