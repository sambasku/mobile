import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/jinye/domain/jinye_models.dart';
import 'package:sambasku_mobile/shared/entity_comments/entity_comment.dart';

void main() {
  test('EntityComment parses user.is_verifier', () {
    final c = EntityComment.fromJson(
      {
        'id': 'c1',
        'event_id': 'e1',
        'body': 'halo',
        'status': 'published',
        'is_edited': false,
        'created_at': '2026-01-01T00:00:00.000Z',
        'user': {
          'user_id': 'u1',
          'username': 'veri',
          'display_name': 'Veri',
          'is_verifier': true,
        },
      },
      entityIdKey: 'event_id',
    );
    expect(c.isVerifier, isTrue);
  });

  test('EntityComment defaults isVerifier false', () {
    final c = EntityComment.fromJson(
      {
        'id': 'c2',
        'place_id': 'p1',
        'body': 'hi',
        'status': 'published',
        'is_edited': false,
        'created_at': '2026-01-01T00:00:00.000Z',
        'user': {'user_id': 'u2'},
      },
      entityIdKey: 'place_id',
    );
    expect(c.isVerifier, isFalse);
  });

  test('JinyeComment parses is_verifier including nested replies', () {
    final c = JinyeComment.fromJson({
      'id': 'jc1',
      'jinye_id': 'j1',
      'body': 'komen',
      'created_at': '2026-01-01T00:00:00.000Z',
      'user_id': 'u1',
      'is_verifier': true,
      'replies': [
        {
          'id': 'jc2',
          'jinye_id': 'j1',
          'parent_id': 'jc1',
          'body': 'reply',
          'created_at': '2026-01-01T00:01:00.000Z',
          'user_id': 'u2',
          'is_verifier': false,
        },
      ],
    });
    expect(c.isVerifier, isTrue);
    expect(c.replies.single.isVerifier, isFalse);
  });
}
