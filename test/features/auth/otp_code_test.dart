import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/otp_code.dart';

void main() {
  group('otp_code', () {
    test('normalize huruf kecil dan tanda hubung', () {
      expect(normalizeOtpInput('a4k-9m2'), 'A4K9M2');
      expect(normalizeOtpInput('A4K9M2'), 'A4K9M2');
    });

    test('format tampilan XXX-YYY', () {
      expect(formatOtpDisplay('a4k9m2'), 'A4K-9M2');
      expect(formatOtpDisplay('A4K'), 'A4K');
      expect(formatOtpDisplay('A4K9M2ZZ'), 'A4K-9M2');
    });
  });
}
