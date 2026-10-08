import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/deep_link_params.dart';

void main() {
  group('sanitizeEmailParam (#70)', () {
    test('email valid lolos', () {
      expect(sanitizeEmailParam('user@example.com'), 'user@example.com');
    });

    test('tanpa @ / spasi / karakter injeksi → dibuang', () {
      expect(sanitizeEmailParam('tanpa-at.example.com'), '');
      expect(sanitizeEmailParam('a b@example.com'), '');
      expect(sanitizeEmailParam('<script>@x.com'), '');
      expect(sanitizeEmailParam(''), '');
    });

    test('nilai non-email apa pun dari query → dibuang', () {
      expect(sanitizeEmailParam('1 OR 1=1'), '');
      expect(sanitizeEmailParam('a@b'), ''); // tanpa TLD
    });
  });

  group('sanitizeResetTokenParam (#70)', () {
    test('token hex 96 (format server randomBytes(48)) lolos', () {
      final token = 'ab' * 48;
      expect(sanitizeResetTokenParam(token), token);
    });

    test('charset aneh / terlalu pendek / terlalu panjang → dibuang', () {
      expect(sanitizeResetTokenParam('token"; DROP TABLE users;--'), '');
      expect(sanitizeResetTokenParam('<script>alert(1)</script>'), '');
      expect(sanitizeResetTokenParam('abc123'), ''); // < 32
      expect(sanitizeResetTokenParam('a' * 300), ''); // > 256
      expect(sanitizeResetTokenParam(''), '');
    });

    test('alnum panjang (format token fleksibel) tetap lolos', () {
      final token = 'A1b2C3d4' * 8; // 64 alnum
      expect(sanitizeResetTokenParam(token), token);
    });
  });
}
