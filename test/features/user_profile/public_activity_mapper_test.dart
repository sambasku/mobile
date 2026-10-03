import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/user_profile/domain/entities/public_profile.dart';
import 'package:sambasku_mobile/features/user_profile/domain/public_activity_mapper.dart';

void main() {
  const profile = PublicProfile(
    username: 'budi',
    displayName: 'Budi',
    role: 'contributor',
    isVerifier: false,
    joinedAt: '2026-08-01T00:00:00.000Z',
    contributionsApproved: 1,
    verificationsDone: 2,
    commentsPublished: 3,
    bio: null,
    avatarUrl: null,
  );

  var seq = 0;
  PublicActivityItem item(String kind, {String? wordId}) => PublicActivityItem(
        id: '01ACT${(seq++).toString().padLeft(20, '0')}',
        kind: kind,
        occurredAt: '2026-09-30T10:00:00.000Z',
        summary: 'ringkasan',
        wordId: wordId,
        lemma: 'kumis',
      );

  test('kind dipetakan ke enum feed terdekat', () {
    expect(
      mapPublicActivityToFeed(item('contribution'), profile).kind,
      FeedActivityKind.word,
    );
    expect(
      mapPublicActivityToFeed(item('comment'), profile).kind,
      FeedActivityKind.comment,
    );
    expect(
      mapPublicActivityToFeed(item('verification'), profile).kind,
      FeedActivityKind.vote,
    );
    expect(
      mapPublicActivityToFeed(item('vote'), profile).kind,
      FeedActivityKind.vote,
    );
  });

  test('vote downvote: arah dibaca dari akhiran body feed tile', () {
    final down = mapPublicActivityToFeed(
      PublicActivityItem(
        id: '01ACTVOTE0000000000000001',
        kind: 'vote',
        occurredAt: '2026-09-30T10:00:00.000Z',
        summary: '"kumis" perlu dicek ulang',
        wordId: 'w1',
        lemma: 'kumis',
      ),
      profile,
    );
    expect(down.kind, FeedActivityKind.vote);
    expect(down.body, '"kumis" perlu dicek ulang');

    final up = mapPublicActivityToFeed(
      PublicActivityItem(
        id: '01ACTVOTE0000000000000002',
        kind: 'vote',
        occurredAt: '2026-09-30T10:00:00.000Z',
        summary: '"kumis" sudah pas',
        wordId: 'w1',
        lemma: 'kumis',
      ),
      profile,
    );
    expect(up.body, '"kumis" sudah pas');
  });

  test('target word terisi dari wordId, aktor dari profil', () {
    final mapped = mapPublicActivityToFeed(item('contribution', wordId: 'w1'), profile);
    expect(mapped.target?.type, 'word');
    expect(mapped.target?.id, 'w1');
    expect(mapped.actor?.username, 'budi');
    expect(mapped.actor?.displayName, 'Budi');
    expect(mapped.body, 'ringkasan');
    expect(mapped.createdAt, '2026-09-30T10:00:00.000Z');

    final noTarget = mapPublicActivityToFeed(item('comment'), profile);
    expect(noTarget.target, isNull);
  });
}
