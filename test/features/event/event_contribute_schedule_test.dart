import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/event/domain/event_contribute_schedule.dart';
import 'package:sambasku_mobile/features/event/domain/event_schedule_format.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'dart:ui';

void main() {
  group('combineEventDateTime', () {
    test('jam null → 00:00', () {
      final date = DateTime.utc(2026, 3, 1);
      final result = combineEventDateTime(date, null);
      expect(result, DateTime(2026, 3, 1, 0, 0));
    });

    test('tanggal null → null', () {
      expect(combineEventDateTime(null, const FTime(8)), isNull);
    });
  });

  group('eventScheduleOrderingInvalid', () {
    final startDate = DateTime.utc(2026, 3, 10);
    final sameEndDate = DateTime.utc(2026, 3, 10);
    final laterEndDate = DateTime.utc(2026, 3, 12);

    test('tanpa tanggal selesai → valid', () {
      expect(
        eventScheduleOrderingInvalid(
          startDate: startDate,
          endDate: null,
          endTime: null,
          startsAt: DateTime(2026, 3, 10, 8),
          endsAt: null,
        ),
        isFalse,
      );
    });

    test('jam selesai null, hari sama, jam mulai terisi → valid (#319)', () {
      final startsAt = combineEventDateTime(startDate, const FTime(8))!;
      final endsAt = combineEventDateTime(sameEndDate, null);
      expect(
        eventScheduleOrderingInvalid(
          startDate: startDate,
          endDate: sameEndDate,
          endTime: null,
          startsAt: startsAt,
          endsAt: endsAt,
        ),
        isFalse,
      );
    });

    test('jam selesai null, tanggal selesai sebelum mulai → invalid', () {
      final startsAt = combineEventDateTime(startDate, null)!;
      final endsAt = combineEventDateTime(DateTime.utc(2026, 3, 9), null);
      expect(
        eventScheduleOrderingInvalid(
          startDate: startDate,
          endDate: DateTime.utc(2026, 3, 9),
          endTime: null,
          startsAt: startsAt,
          endsAt: endsAt,
        ),
        isTrue,
      );
    });

    test('keduanya punya jam, selesai sebelum mulai → invalid', () {
      final startsAt = combineEventDateTime(startDate, const FTime(14))!;
      final endsAt = combineEventDateTime(sameEndDate, const FTime(10));
      expect(
        eventScheduleOrderingInvalid(
          startDate: startDate,
          endDate: sameEndDate,
          endTime: const FTime(10),
          startsAt: startsAt,
          endsAt: endsAt,
        ),
        isTrue,
      );
    });

    test('pratinjau tanpa jam, ada tanggal selesai → strip - (#319)', () {
      final l10n = lookupAppLocalizations(const Locale('id'));
      final text = formatEventContributeSchedulePreview(
        l10n,
        startDate: DateTime.utc(2026, 3, 10),
        startTime: const FTime(8),
        endDate: DateTime.utc(2026, 3, 12),
        endTime: null,
      );
      expect(text, contains(' - '));
      expect(text, contains('Pratinjau:'));
    });

    test('jam selesai terisi, multi-day → valid', () {
      final startsAt = combineEventDateTime(startDate, const FTime(8))!;
      final endsAt = combineEventDateTime(laterEndDate, const FTime(17));
      expect(
        eventScheduleOrderingInvalid(
          startDate: startDate,
          endDate: laterEndDate,
          endTime: const FTime(17),
          startsAt: startsAt,
          endsAt: endsAt,
        ),
        isFalse,
      );
    });
  });
}