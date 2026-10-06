import 'package:flutter_test/flutter_test.dart';

import 'package:sambasku_mobile/features/admin_analytics/domain/admin_access.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/dashboard_mappers.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/entities/analytics_activity_item.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/entities/dashboard_stats.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/format_analytics_count.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/merge_analytics_activity.dart';
import 'package:sambasku_mobile/features/admin_analytics/domain/today_vs_yesterday.dart';

void main() {
  group('canAccessAdminAnalytics', () {
    test('root dan admin diizinkan', () {
      expect(canAccessAdminAnalytics('root'), isTrue);
      expect(canAccessAdminAnalytics('admin'), isTrue);
    });

    test('reviewer, editor, contributor ditolak', () {
      expect(canAccessAdminAnalytics('reviewer'), isFalse);
      expect(canAccessAdminAnalytics('editor'), isFalse);
      expect(canAccessAdminAnalytics('contributor'), isFalse);
      expect(canAccessAdminAnalytics(null), isFalse);
    });
  });

  group('buildTodayVsYesterday', () {
    ActivityDailyPoint point({
      required String date,
      int contributions = 0,
      int votes = 0,
      int comments = 0,
      int newUsers = 0,
      int searches = 0,
    }) {
      return ActivityDailyPoint(
        date: date,
        contributions: contributions,
        votes: votes,
        comments: comments,
        newUsers: newUsers,
        searches: searches,
      );
    }

    test('menghitung delta vs hari sebelumnya', () {
      final metrics = buildTodayVsYesterday([
        point(date: '2026-09-25', contributions: 2, votes: 10, comments: 1),
        point(
          date: '2026-09-26',
          contributions: 5,
          votes: 8,
          comments: 1,
          newUsers: 2,
        ),
      ]);
      expect(
        metrics.firstWhere((m) => m.key == TodayMetricKey.contributions),
        isA<TodayVsYesterdayMetric>()
            .having((m) => m.today, 'today', 5)
            .having((m) => m.yesterday, 'yesterday', 2)
            .having((m) => m.delta, 'delta', 3),
      );
      expect(
        metrics.firstWhere((m) => m.key == TodayMetricKey.votes).delta,
        -2,
      );
      expect(
        metrics.firstWhere((m) => m.key == TodayMetricKey.comments).delta,
        0,
      );
      expect(
        metrics.firstWhere((m) => m.key == TodayMetricKey.newUsers).delta,
        2,
      );
    });

    test('sembunyikan delta jika hanya satu titik', () {
      final metrics = buildTodayVsYesterday([
        point(date: '2026-09-26', contributions: 3),
      ]);
      expect(
        metrics.every((m) => m.delta == null && m.yesterday == null),
        isTrue,
      );
      expect(metrics.first.today, 3);
    });
  });

  group('formatDelta', () {
    test('memformat tanda + / -', () {
      expect(formatDelta(3), '+3');
      expect(formatDelta(-2), '-2');
      expect(formatDelta(0), '0');
    });
  });

  group('formatAnalyticsCount', () {
    test('compact ribuan', () {
      expect(formatAnalyticsCount(999), '999');
      expect(formatAnalyticsCount(1000), '1k');
      expect(formatAnalyticsCount(1500), '1.5k');
      expect(formatAnalyticsCount(15000), '15k');
      expect(formatAnalyticsCount(-1500), '-1.5k');
    });
  });

  group('normalizeDashboardStats', () {
    Map<String, dynamic> wireFixture() => {
      'words': {
        'total': 1,
        'verified': 0,
        'deleted': 0,
        'by_status': {
          'draft': 0,
          'pending_review': 0,
          'published': 1,
          'rejected': 0,
        },
      },
      'contributions': {
        'total': 2,
        'by_status': {
          'pending': 1,
          'approved': 1,
          'rejected': 0,
          'corrected': 0,
        },
      },
      'users': {
        'active': 1,
        'online_recently': 0,
        'by_role': {
          'root': 0,
          'admin': 1,
          'editor': 0,
          'reviewer': 0,
          'contributor': 0,
        },
      },
      'activity': {
        'audit_logs_last_7_days': 5,
        'daily_last_30_days': [
          {
            'date': '2026-09-20',
            'contributions': 1,
            'votes': 0,
            'comments': 2,
            'new_users': 1,
            'searches': 3,
          },
          {
            'date': '2026-09-27',
            'contributions': 2,
            'votes': 5,
            'comments': 0,
            'new_users': 0,
            'searches': 4,
          },
        ],
      },
      'problems': {
        'open': 3,
        'closed': 5,
        'by_source': {
          'bug_reports': {'open': 1, 'closed': 3},
          'word_reports': {'open': 2, 'closed': 2},
        },
      },
      'verifier_applications': {
        'pending': 2,
        'approved': 4,
        'rejected': 1,
      },
    };

    test('memetakan wire + pad tetap 30 hari WIB', () {
      // 2026-09-26T20:00:00Z = 2026-09-27 WIB
      final now = DateTime.utc(2026, 9, 26, 20);
      final stats = normalizeDashboardStats(wireFixture(), now: now);
      expect(stats.contributions.total, 2);
      expect(stats.activity.auditLogsLast7Days, 5);
      expect(stats.activity.dailyLast30Days, hasLength(30));
      expect(stats.activity.dailyLast30Days.first.date, '2026-08-29');
      expect(stats.activity.dailyLast30Days.last.date, '2026-09-27');
      expect(stats.activity.dailyLast30Days.last.contributions, 2);
      expect(stats.activity.dailyLast30Days.last.votes, 5);
      final sep20 = stats.activity.dailyLast30Days
          .firstWhere((p) => p.date == '2026-09-20');
      expect(sep20.contributions, 1);
      expect(sep20.comments, 2);
      expect(sep20.newUsers, 1);
      expect(sep20.searches, 3);
      expect(stats.activity.dailyLast30Days.last.searches, 4);
      expect(stats.problems.open, 3);
      expect(stats.problems.bySource.bugReports.open, 1);
      expect(stats.verifierApplications.pending, 2);
    });

    test('problems hilang → open/closed 0', () {
      final wire = wireFixture()..remove('problems');
      final stats = normalizeDashboardStats(wire);
      expect(stats.problems.open, 0);
      expect(stats.problems.closed, 0);
    });
  });

  group('wibDateString / shiftCalendarDate', () {
    test('WIB offset dari UTC', () {
      expect(wibDateString(DateTime.utc(2026, 9, 26, 20)), '2026-09-27');
      expect(wibDateString(DateTime.utc(2026, 9, 26, 16, 59)), '2026-09-26');
    });

    test('shift kalender', () {
      expect(shiftCalendarDate('2026-09-27', -1), '2026-09-26');
      expect(shiftCalendarDate('2026-03-01', -1), '2026-02-28');
    });
  });

  group('searchMissActivityBody', () {
    test('copy bantu isi', () {
      expect(
        searchMissActivityBody('kalintiak'),
        'mencari kalintiak tapi tidak terdapat. Bantu isi.',
      );
      expect(
        searchMissActivityBody('  '),
        'mencari … tapi tidak terdapat. Bantu isi.',
      );
    });
  });

  group('mergeAnalyticsActivity', () {
    AnalyticsActivityItem item({
      required AnalyticsActivityKind kind,
      required String id,
      required String createdAt,
    }) {
      return AnalyticsActivityItem(
        kind: kind,
        id: id,
        createdAt: createdAt,
        actorLabel: 'User',
        body: 'body-$id',
      );
    }

    test('urut terbaru dulu', () {
      final merged = mergeAnalyticsActivity([
        item(
          kind: AnalyticsActivityKind.comment,
          id: 'a',
          createdAt: '2026-09-28T10:00:00.000Z',
        ),
        item(
          kind: AnalyticsActivityKind.vote,
          id: 'b',
          createdAt: '2026-09-28T12:00:00.000Z',
        ),
        item(
          kind: AnalyticsActivityKind.discussion,
          id: 'c',
          createdAt: '2026-09-28T11:00:00.000Z',
        ),
      ]);
      expect(merged.map((e) => e.id).toList(), ['b', 'c', 'a']);
    });

    test('cap per kind lalu limit global', () {
      final votes = List.generate(
        8,
        (i) => item(
          kind: AnalyticsActivityKind.vote,
          id: 'v$i',
          createdAt:
              '2026-09-28T${(20 - i).toString().padLeft(2, '0')}:00:00.000Z',
        ),
      );
      final comments = List.generate(
        3,
        (i) => item(
          kind: AnalyticsActivityKind.comment,
          id: 'c$i',
          createdAt:
              '2026-09-28T${(15 - i).toString().padLeft(2, '0')}:00:00.000Z',
        ),
      );
      final merged = mergeAnalyticsActivity(
        [...votes, ...comments],
        perKindCap: 5,
        limit: 12,
      );
      expect(
        merged.where((e) => e.kind == AnalyticsActivityKind.vote),
        hasLength(5),
      );
      expect(
        merged.where((e) => e.kind == AnalyticsActivityKind.comment),
        hasLength(3),
      );
      expect(merged, hasLength(8));
      expect(merged.first.id, 'v0');
    });

    test('limit global memotong setelah cap', () {
      final items = <AnalyticsActivityItem>[
        for (final kind in AnalyticsActivityKind.values)
          for (var i = 0; i < 5; i++)
            item(
              kind: kind,
              id: '${kind.name}$i',
              createdAt:
                  '2026-09-${(28 - i).toString().padLeft(2, '0')}T12:00:00.000Z',
            ),
      ];
      final merged = mergeAnalyticsActivity(
        items,
        perKindCap: 5,
        limit: 12,
      );
      expect(merged, hasLength(12));
    });
  });
}
