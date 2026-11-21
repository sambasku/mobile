import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/set_password/data/models/set_password_request_dto.dart';

void main() {
  // Field bukti provider yang null ikut body (includeIfNull default) →
  // ditolak z.string().optional() API → 400 "Beberapa isian belum sesuai".
  group('SetPasswordRequestDto.toJson', () {
    test('Google: key bukti lain yang null tidak ikut body', () {
      final json = const SetPasswordRequestDto(
        provider: 'google',
        idToken: 'eyJ.google',
        newPassword: 'PasswordBaru123',
        confirmPassword: 'PasswordBaru123',
      ).toJson();

      expect(json['provider'], 'google');
      expect(json['id_token'], 'eyJ.google');
      expect(json['new_password'], 'PasswordBaru123');
      expect(json['confirm_password'], 'PasswordBaru123');
      expect(json.containsKey('access_token'), isFalse);
      expect(json.containsKey('code'), isFalse);
      expect(json.containsKey('redirect_uri'), isFalse);
      expect(json.containsKey('code_verifier'), isFalse);
    });

    test('GitHub code flow: id_token/access_token null tidak ikut body', () {
      final json = const SetPasswordRequestDto(
        provider: 'github',
        code: 'oauth-code',
        redirectUri: 'sambasku://app/oauth/github',
        codeVerifier: 'pkce-verifier',
        newPassword: 'PasswordBaru123',
        confirmPassword: 'PasswordBaru123',
      ).toJson();

      expect(json['provider'], 'github');
      expect(json['code'], 'oauth-code');
      expect(json['redirect_uri'], 'sambasku://app/oauth/github');
      expect(json['code_verifier'], 'pkce-verifier');
      expect(json['new_password'], 'PasswordBaru123');
      expect(json['confirm_password'], 'PasswordBaru123');
      expect(json.containsKey('id_token'), isFalse);
      expect(json.containsKey('access_token'), isFalse);
    });
  });
}
