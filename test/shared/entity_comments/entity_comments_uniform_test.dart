import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/entity_comments/entity_comment.dart';
import 'package:sambasku_mobile/shared/entity_comments/entity_comment_providers.dart';
import 'package:sambasku_mobile/shared/ugc_comment_lemma/ugc_comment_lemma_interaction.dart';

void main() {
  group('Uniform EntityCommentTarget & EntityComment (#375)', () {
    test('all 8 targets expose valid voteTargetType and lemma anchor mapping', () {
      expect(EntityCommentTarget.values.length, 8);
      expect(EntityCommentTarget.word.voteTargetType, 'comment');
      expect(EntityCommentTarget.article.voteTargetType, 'article_comment');
      expect(EntityCommentTarget.jinye.voteTargetType, 'jinye_comment');
      expect(EntityCommentTarget.place.voteTargetType, 'place_comment');
      expect(EntityCommentTarget.usaha.voteTargetType, 'usaha_comment');
      expect(EntityCommentTarget.cuisine.voteTargetType, 'cuisine_comment');
      expect(EntityCommentTarget.event.voteTargetType, 'event_comment');
      expect(EntityCommentTarget.karya.voteTargetType, 'karya_comment');

      // Jinye has no ugc-comment-lemma anchor; all other 7 do.
      expect(anchorForEntityCommentTarget(EntityCommentTarget.jinye), isNull);
      for (final t in EntityCommentTarget.values) {
        if (t == EntityCommentTarget.jinye) continue;
        expect(anchorForEntityCommentTarget(t), isNotNull);
      }
    });

    test('parses 2-level nested replies and counts totalLoadedCount accurately', () {
      final root = EntityComment.fromJson({
        'id': '01ROOT00000000000000000000',
        'word_id': '01WORD00000000000000000000',
        'parent_id': null,
        'body': 'Komentar akar',
        'status': 'published',
        'created_at': '2026-11-27T10:00:00.000Z',
        'user': {
          'id': '01USER10000000000000000000',
          'username': 'penulis',
          'display_name': 'Penulis',
        },
        'replies': [
          {
            'id': '01REPLY1000000000000000000',
            'word_id': '01WORD00000000000000000000',
            'parent_id': '01ROOT00000000000000000000',
            'body': '@penulis Balasan 1',
            'status': 'published',
            'created_at': '2026-11-27T10:01:00.000Z',
            'user_id': '01USER20000000000000000000',
            'username': 'pembalas',
            'display_name': 'Pembalas',
          },
          {
            'id': '01REPLY2000000000000000000',
            'word_id': '01WORD00000000000000000000',
            'parent_id': '01ROOT00000000000000000000',
            'body': '@pembalas Balasan 2',
            'status': 'published',
            'created_at': '2026-11-27T10:02:00.000Z',
            'user': {
              'id': '01USER30000000000000000000',
              'username': 'ketiga',
              'display_name': 'Ketiga',
            },
          },
        ],
      }, entityIdKey: 'word_id');

      expect(root.parentId, isNull);
      expect(root.replies.length, 2);
      expect(root.replies[0].parentId, root.id);
      expect(root.replies[0].username, 'pembalas');
      expect(root.replies[1].username, 'ketiga');

      final state = EntityCommentListState(items: [root]);
      expect(state.totalLoadedCount, 3);
    });

    test('allImages combines imageUrl and legacy Jinye images list without duplicates', () {
      final comment = EntityComment.fromJson({
        'id': '01JINYE0000000000000000000',
        'jinye_id': '01POST00000000000000000000',
        'body': 'Foto jinye',
        'status': 'published',
        'created_at': '2026-11-27T10:00:00.000Z',
        'image_url': 'https://example.com/a.jpg',
        'images': [
          'https://example.com/a.jpg',
          'https://example.com/b.jpg',
        ],
        'user_id': '01USER10000000000000000000',
      }, entityIdKey: 'jinye_id');

      expect(comment.allImages.map((e) => e.publicUrl).toList(), [
        'https://example.com/a.jpg',
        'https://example.com/b.jpg',
      ]);
    });
  });
}
