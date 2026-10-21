import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/share/domain/word_public_url.dart';

void main() {
  test('wordPublicUrl memakai locale id dan meng-encode lemma', () {
    final plain = wordPublicUrl('capal');
    expect(plain, isNotNull);
    expect(plain, endsWith('/id/words/capal'));
    expect(plain!.contains('/words/capal'), isTrue);
    expect(plain.contains('/id/id/'), isFalse);

    expect(wordPublicUrl('a&b'), endsWith('/id/words/a%26b'));
    expect(wordPublicUrl('  '), isNull);
  });

  test('wordShareLinkMessage menaruh lemma lalu URL', () {
    final message = wordShareLinkMessage('capal');
    expect(message, startsWith('capal\n'));
    expect(message, endsWith('/id/words/capal'));
  });

  test('nativeWordPathFromPublicLink hanya untuk /id/words/<lemma>', () {
    expect(
      nativeWordPathFromPublicLink(
        Uri.parse('https://sambasku.com/id/words/capal'),
      ),
      '/words/capal',
    );
    expect(
      nativeWordPathFromPublicLink(
        Uri.parse('https://sambasku.com/id/words/a%26b'),
      ),
      '/words/a%26b',
    );
    expect(
      nativeWordPathFromPublicLink(
        Uri.parse('https://sambasku.com/words/capal'),
      ),
      isNull,
    );
    expect(
      nativeWordPathFromPublicLink(Uri.parse('https://sambasku.com/id/words')),
      isNull,
    );
    expect(
      nativeWordPathFromPublicLink(Uri.parse('sambasku://app/words/capal')),
      isNull,
    );
  });
}
