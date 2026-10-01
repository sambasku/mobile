import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/models/image_attribution.dart';

void main() {
  test('fromJson respons detail (provider ikut, kosong dibuang)', () {
    final a = ImageAttribution.fromJson({
      'name': ' Ada ',
      'url': 'https://www.flickr.com/photos/x/1',
      'license': 'CC BY 2.0',
      'license_url': '',
      'source': 'flickr',
      'provider': 'openverse',
    })!;
    expect(a.name, 'Ada');
    expect(a.provider, 'openverse');
    expect(a.licenseUrl, isNull);
    expect(ImageAttribution.fromJson({'name': ''}), isNull);
    expect(ImageAttribution.fromJson(null), isNull);
  });

  test('toJson membuang URL non-https (API menolak) dan field null', () {
    const a = ImageAttribution(
      name: 'Ada',
      provider: 'openverse',
      url: 'http://flickr.com/x',
      license: 'CC0 1.0',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
    );
    expect(a.toJson(), {
      'name': 'Ada',
      'license': 'CC0 1.0',
      'license_url': 'https://creativecommons.org/publicdomain/zero/1.0/',
    });
  });

  test('withUnsplashUtm hanya menambah UTM ke link Unsplash tanpa UTM', () {
    final added = withUnsplashUtm(Uri.parse('https://unsplash.com/@ada'));
    expect(added.queryParameters['utm_source'], 'sambasku');
    expect(added.queryParameters['utm_medium'], 'referral');
    final other = Uri.parse('https://pixabay.com/photos/1');
    expect(withUnsplashUtm(other), other);
    final kept = unsplashProfileUri('ada');
    expect(withUnsplashUtm(kept), kept);
  });
}
