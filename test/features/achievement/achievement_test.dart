import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/achievement/data/models/achievement_dto.dart';
import 'package:sambasku_mobile/features/achievement/domain/entities/achievement.dart';
import 'package:sambasku_mobile/features/achievement/presentation/widgets/achievement_badge_grid.dart';

Achievement _badge(String code, {String? family, int? level}) => Achievement(
  id: code,
  code: code,
  title: code,
  description: '',
  category: 'kontribusi',
  rewardType: 'badge',
  isActive: true,
  family: family,
  level: level,
  userAchievementId: 'award-$code',
);

void main() {
  test('topTierPerFamily: hanya level tertinggi per family yang tampil', () {
    final result = AchievementBadgeGrid.topTierPerFamily([
      _badge('kata-1', family: 'kata-disetujui', level: 1),
      _badge('kata-3', family: 'kata-disetujui', level: 3),
      _badge('kata-2', family: 'kata-disetujui', level: 2),
      _badge('beta-tester'),
    ]);

    expect(result.map((e) => e.code), containsAll(['kata-3', 'beta-tester']));
    expect(result.length, 2);
  });

  test('AchievementDto memetakan award id + border aktif', () {
    final dto = AchievementDto.fromJson(const {
      'id': '01AAAAAAAAAAAAAAAAAAAAAAAA',
      'code': 'angkatan-ke-1',
      'title': 'Angkatan Ke-1',
      'description': 'Kohort pertama',
      'category': 'kohort',
      'reward_type': 'profile_border',
      'badge_url': 'https://cdn.example/border.png',
      'family': null,
      'level': null,
      'is_active': true,
      'user_achievement_id': '01BBBBBBBBBBBBBBBBBBBBBBBB',
      'awarded_at': 1767225600,
      'is_active_border': true,
    });

    expect(dto.rewardType, 'profile_border');
    expect(dto.userAchievementId, '01BBBBBBBBBBBBBBBBBBBBBBBB');
    expect(dto.isActiveBorder, isTrue);
    expect(DateTime.fromMillisecondsSinceEpoch(dto.awardedAt! * 1000).year, 2026);
  });

  test('AchievementDto locked: user_achievement_id absen = belum dimiliki', () {
    final dto = AchievementDto.fromJson(const {
      'id': '01AAAAAAAAAAAAAAAAAAAAAAAA',
      'code': 'beta-tester',
      'title': 'Beta Tester',
      'description': 'Fase closed testing',
      'category': 'kohort',
      'reward_type': 'badge',
      'is_active': true,
    });

    expect(dto.userAchievementId, isNull);
    expect(dto.isActiveBorder, isFalse);
  });
}
