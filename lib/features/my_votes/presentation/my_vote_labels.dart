import '../../../l10n/app_localizations.dart';
import '../domain/entities/my_vote_item.dart';

/// Label jenis target vote. Domain hanya menyimpan nilai wire.
String voteTargetLabel(AppLocalizations l10n, String targetType) =>
    switch (targetType) {
      'word' => l10n.myVoteTargetWord,
      'meaning' => l10n.myVoteTargetMeaning,
      'example' => l10n.myVoteTargetExample,
      'pronunciation' => l10n.myVoteTargetPronunciation,
      'word_image' => l10n.myVoteTargetImage,
      'comment' => l10n.myVoteTargetComment,
      'discussion_reply' => l10n.myVoteTargetDiscussionReply,
      'discussion' => l10n.myVoteTargetDiscussion,
      'pantun' => l10n.myVoteTargetPantun,
      'pantun_reply' => l10n.myVoteTargetPantunReply,
      _ => targetType,
    };

/// Judul tile vote: lemma bila ada, selain itu label target / kata hilang.
String myVoteTitle(AppLocalizations l10n, String targetType, String? lemma) {
  final value = lemma?.trim();
  if (value != null && value.isNotEmpty) return value;
  return targetType == 'word'
      ? l10n.myVoteWordGone
      : voteTargetLabel(l10n, targetType);
}

/// Subtitle tile vote: arah · jenis target · tanggal.
String myVoteSubtitle(
  AppLocalizations l10n,
  MyVoteItem item,
  String date,
) {
  final direction = item.value == 1
      ? l10n.voteSemanticsUpvote
      : l10n.voteSemanticsDownvote;
  return '$direction · ${voteTargetLabel(l10n, item.targetType)} · $date';
}
