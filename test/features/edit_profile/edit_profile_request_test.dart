import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/edit_profile/data/models/my_profile_dto.dart';

void main() {
  // #98: submit profil selalu kirim has_read_contribution_guide: null
  // (includeIfNull default) → ditolak z.literal(true).optional() backend
  // → 422 "Beberapa isian belum sesuai" walau isian user valid.
  group('UpdateMyProfileRequestDto.toJson (#98)', () {
    test('null has_read_contribution_guide tak ikut dalam body', () {
      final json =
          const UpdateMyProfileRequestDto(displayName: 'Kapsaloy', bio: null)
              .toJson();
      expect(json.containsKey('has_read_contribution_guide'), isFalse);
      expect(json['display_name'], 'Kapsaloy');
      expect(json.containsKey('bio'), isTrue, reason: 'bio null = kosongkan');
    });

    test('true tetap dikirim', () {
      final json = const UpdateMyProfileRequestDto(
        displayName: 'Kapsaloy',
        hasReadContributionGuide: true,
      ).toJson();
      expect(json['has_read_contribution_guide'], isTrue);
    });
  });
}
