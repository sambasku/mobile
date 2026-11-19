import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/models/word_detail_dto.dart';
import 'package:sambasku_mobile/shared/content_related/content_related_link.dart';

void main() {
  test('parse mock lemma detail', () {
    final map = {
      'id': '01JWORDMAKAN0000000000000A',
      'lemma': 'makan',
      'language_id': 'lang-sbs',
      'word_type': 'word',
      'status': 'published',
      'is_verified': true,
      'is_corrected': false,
    };
    final dto = WordDetailDto.fromJson(map);
    expect(dto.id, '01JWORDMAKAN0000000000000A');
    final related = ContentRelatedLink.listFromJson(null);
    expect(related, isEmpty);
  });
}
