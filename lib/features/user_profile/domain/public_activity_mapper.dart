import '../../activity/domain/entities/feed_activity_item.dart';
import 'entities/public_profile.dart';

/// Memetakan aktivitas publik ke item feed untuk ditampilkan di tile.
///
/// Dipakai oleh ActivityCategorySheet dan dites di
/// test/features/user_profile/public_activity_mapper_test.dart.
FeedActivityItem mapPublicActivityToFeed(
  PublicActivityItem item,
  PublicProfile profile,
) {
  final kind = switch (item.kind) {
    'comment' => FeedActivityKind.comment,
    'vote' => FeedActivityKind.vote,
    // #99: kategori verification profil = event word_verified - check, bukan panah vote
    'verification' => FeedActivityKind.verification,
    _ => FeedActivityKind.word,
  };
  return FeedActivityItem(
    id: item.id,
    kind: kind,
    createdAt: item.occurredAt,
    body: item.summary,
    actor: FeedActivityActor(
      username: profile.username,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
    ),
    target: item.wordId == null
        ? null
        : FeedActivityTarget(type: 'word', id: item.wordId!),
  );
}
