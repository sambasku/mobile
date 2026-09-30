import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/services/notification_navigation.dart';

void main() {
  test('listing Play Store jadi market://details', () {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.iamutaki.sambasku',
    );
    expect(
      playStoreMarketUri(uri),
      Uri.parse('market://details?id=com.iamutaki.sambasku'),
    );
  });

  test('query lain tidak menggeser id', () {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.iamutaki.sambasku&hl=id',
    );
    expect(
      playStoreMarketUri(uri)?.queryParameters['id'],
      'com.iamutaki.sambasku',
    );
  });

  test('bukan listing Play Store tetap null', () {
    expect(
      playStoreMarketUri(Uri.parse('https://github.com/sambasku')),
      isNull,
    );
    expect(
      playStoreMarketUri(
        Uri.parse('https://play.google.com/store/apps/details'),
      ),
      isNull,
    );
  });
}
