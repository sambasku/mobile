import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/contribution/presentation/pages/contribute_page.dart';

void main() {
  group('contributeSuccessFromBeranda', () {
    test('beranda', () {
      expect(contributeSuccessFromBeranda('beranda'), isTrue);
    });

    test('kontribusi shortcut', () {
      expect(contributeSuccessFromBeranda('kontribusi'), isFalse);
    });

    test('review session deck', () {
      expect(contributeSuccessFromBeranda('review_session'), isFalse);
    });

    test('null or unknown', () {
      expect(contributeSuccessFromBeranda(null), isFalse);
      expect(contributeSuccessFromBeranda('search_miss'), isFalse);
    });
  });
}