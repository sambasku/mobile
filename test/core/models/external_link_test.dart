import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/models/external_link.dart';

void main() {
  group('withSambaskuUtm (rule external-link-utm)', () {
    test('menambah utm_source+utm_medium pada link eksternal', () {
      final out = withSambaskuUtm(Uri.parse('https://instagram.com/p/abc123'));
      expect(out.queryParameters['utm_source'], 'sambasku.com');
      expect(out.queryParameters['utm_medium'], 'referral');
      expect(out.host, 'instagram.com');
    });

    test('query yang sudah ada tetap utuh', () {
      final out = withSambaskuUtm(
        Uri.parse('https://example.com/a?x=1&y=2'),
      );
      expect(out.queryParameters['x'], '1');
      expect(out.queryParameters['y'], '2');
      expect(out.queryParameters['utm_source'], 'sambasku.com');
    });

    test('tidak menimpa utm_source yang sudah ada (mis. Unsplash)', () {
      final uri = Uri.parse(
        'https://unsplash.com/@foto?utm_source=sambasku&utm_medium=referral',
      );
      expect(withSambaskuUtm(uri), uri);
    });

    test('link ke domain sendiri tidak diberi UTM', () {
      final own = Uri.parse('https://sambasku.com/acara');
      expect(withSambaskuUtm(own), own);
      final api = Uri.parse('https://api.sambasku.com/api/v1/events');
      expect(withSambaskuUtm(api), api);
    });

    test('input non-https dikembalikan apa adanya', () => expect(
      withSambaskuUtm(Uri.parse('http://example.com/')),
      Uri.parse('http://example.com/'),
    ));
  });

  group('isOwnHost', () {
    test('menerima domain sendiri dan sub-domainnya', () {
      expect(isOwnHost('sambasku.com'), isTrue);
      expect(isOwnHost('www.sambasku.com'), isTrue);
      expect(isOwnHost('render.sambasku.com'), isTrue);
    });

    test('menolak domain pihak ketiga', () {
      expect(isOwnHost('instagram.com'), isFalse);
      expect(isOwnHost('sambasku.com.evil.example'), isFalse);
    });
  });
}
