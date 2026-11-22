import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/suggest_edit/domain/suggest_category.dart';

void main() {
  test('buildChangeUsageLabels memetakan diff add/remove', () {
    final out = buildChangeUsageLabels(
      original: {'informal', 'kasar'},
      selected: {'kasar', 'seksual'},
    );
    expect(out, {
      'usage_labels_to_add': ['seksual'],
      'usage_labels_to_remove': ['informal'],
    });
  });

  test('buildChangeUsageLabels null jika tidak ada perubahan', () {
    expect(
      buildChangeUsageLabels(
        original: {'kasar'},
        selected: {'kasar'},
      ),
      isNull,
    );
  });
}