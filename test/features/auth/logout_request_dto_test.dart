import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/auth/data/models/logout_request_dto.dart';

void main() {
  test(
    'LogoutRequestDto.toJson memakai refresh_token + client_type mobile',
    () {
      const dto = LogoutRequestDto(refreshToken: 'rfg.abc');

      expect(dto.toJson(), {
        'refresh_token': 'rfg.abc',
        'client_type': 'mobile',
      });
    },
  );
}
