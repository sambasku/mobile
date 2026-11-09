import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/jinye/domain/jinye_models.dart';

void main() {
  test('jinyeProfilePreviewText potong 32 karakter + elipsis', () {
    const full = 'Aku baru makan nasi goreng tadi pagi';
    expect(jinyeProfilePreviewText(full), 'Aku baru makan nasi goreng tadi...');
    expect(jinyeProfilePreviewText('Halo'), 'Halo');
    expect(jinyeProfilePreviewText(''), '');
  });
}
