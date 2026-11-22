import 'package:flutter_test/flutter_test.dart';

import 'package:sambasku_mobile/features/baleho/domain/points_history_models.dart';

void main() {
  test('parses full wire payload', () {
    final view = UserPointsHistoryViewData.fromJson({
      'username': 'ibnuul',
      'history': [
        {
          'week_id': '2026-W47',
          'submitted_points': 10,
          'approved_points': 4,
          'verification_points': 2,
          'combined': 16,
          'xp_at_week_end': 120,
          'created_at': '2026-11-23T00:00:00Z',
        },
        {
          'week_id': '2026-W46',
          'submitted_points': 5,
          'approved_points': 0,
          'verification_points': 4,
          'combined': 9,
          'xp_at_week_end': 104,
          'created_at': '2026-11-16T00:00:00Z',
        },
      ],
    });

    expect(view.username, 'ibnuul');
    expect(view.history, hasLength(2));

    final newest = view.history.first;
    expect(newest.weekId, '2026-W47');
    expect(newest.submittedPoints, 10);
    expect(newest.approvedPoints, 4);
    expect(newest.verificationPoints, 2);
    expect(newest.combined, 16);
    expect(newest.xpAtWeekEnd, 120);
    expect(newest.createdAt, DateTime.utc(2026, 11, 23));
  });

  test('tolerates missing/null fields', () {
    final item = UserWeekPointHistory.fromJson(<String, dynamic>{
      'week_id': null,
      // submitted/approved/verification/combined/xp missing
      'created_at': null,
    });

    expect(item.weekId, '');
    expect(item.submittedPoints, 0);
    expect(item.approvedPoints, 0);
    expect(item.verificationPoints, 0);
    expect(item.combined, 0);
    expect(item.xpAtWeekEnd, 0);
  });

  test('non-map history items skipped', () {
    final view = UserPointsHistoryViewData.fromJson({
      'username': 'x',
      'history': [
        'not-a-map',
        {'week_id': '2026-W47', 'combined': 3},
      ],
    });

    expect(view.history, hasLength(1));
    expect(view.history.first.combined, 3);
  });
}
