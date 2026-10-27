import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/data/models/google_login_request_dto.dart';

void main() {
  test(
    'GoogleLoginRequestDto.toJson memakai id_token + client_type mobile',
    () {
      const dto = GoogleLoginRequestDto(idToken: 'eyJhbGciOiJSUzI1NiIs...');
      expect(dto.toJson(), {
        'id_token': 'eyJhbGciOiJSUzI1NiIs...',
        'client_type': 'mobile',
      });
    },
  );
}
