import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/data/models/facebook_login_request_dto.dart';

void main() {
  test(
    'FacebookLoginRequestDto.toJson memakai access_token + client_type mobile',
    () {
      const dto = FacebookLoginRequestDto(accessToken: 'EAAGm0PX4ZCpsBA...');
      expect(dto.toJson(), {
        'access_token': 'EAAGm0PX4ZCpsBA...',
        'client_type': 'mobile',
      });
    },
  );
}
