import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../entity_comments/entity_comment.dart';
import '../span_lemma/span_lemma_exports.dart';
import 'ugc_comment_lemma_client.dart';

UgcCommentLemmaAnchor anchorForEntityCommentTarget(EntityCommentTarget target) {
  switch (target) {
    case EntityCommentTarget.place:
      return UgcCommentLemmaAnchor.placeComment;
    case EntityCommentTarget.usaha:
      return UgcCommentLemmaAnchor.usahaComment;
    case EntityCommentTarget.cuisine:
      return UgcCommentLemmaAnchor.cuisineComment;
    case EntityCommentTarget.event:
      return UgcCommentLemmaAnchor.eventComment;
    case EntityCommentTarget.karya:
      return UgcCommentLemmaAnchor.karyaComment;
  }
}

/// Tap kata di komentar UGC: sheet makna + taut lemma / usul kata.
Future<void> handleUgcCommentLemmaWordTap(
  BuildContext context,
  WidgetRef ref, {
  required String sheetContextId,
  required UgcCommentLemmaAnchor anchor,
  required String hostId,
  required String commentId,
  required JinyeSpanSelection span,
  JinyeLemmaLink? link,
  required bool isAuth,
  VoidCallback? onLinked,
}) async {
  final result = await showJinyeWordMeaningSheet(
    context,
    jinyeId: sheetContextId,
    span: span,
    link: link,
    isAuth: isAuth,
    commentId: commentId,
    onLinked: onLinked,
    onCreateLink: ({
      required int start,
      required int end,
      required String wordId,
    }) async {
      await ref.read(ugcCommentLemmaClientProvider).createLink(
            anchor: anchor,
            hostId: hostId,
            commentId: commentId,
            start: start,
            end: end,
            wordId: wordId,
          );
      onLinked?.call();
    },
  );
  if (!context.mounted) return;
  handleJinyeWordMeaningSheetResult(context, result);
}
