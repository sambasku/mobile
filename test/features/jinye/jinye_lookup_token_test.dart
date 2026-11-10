import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/jinye/presentation/widgets/jinye_word_meaning_sheet.dart';

void main() {
  test('jinyeLookupToken strip tanda baca ujung', () {
    expect(jinyeLookupToken('apam,'), 'apam');
    expect(jinyeLookupToken('"apam"'), 'apam');
    expect(jinyeLookupToken('  apam.  '), 'apam');
    expect(jinyeLookupToken(''), '');
  });
}
