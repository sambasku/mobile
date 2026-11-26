import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/event/domain/entities/event.dart';

Event _event(DateTime? startsAt) => Event(
  id: 'e1',
  slug: 'pawai',
  name: 'Pawai',
  description: 'Deskripsi',
  categoryId: 'budaya-tradisi',
  startsAt: startsAt,
  endsAt: startsAt,
  occurrenceStatus: EventOccurrenceStatus.upcoming,
  locationText: 'Lapangan',
  status: EventStatus.published,
);

void main() {
  // 2026-10-01T09:00:00Z = 16:00 WIB tanggal 1 Okt.
  final startsAt = DateTime.utc(2026, 10, 1, 9);

  test('sehari sebelum tanggal acara', () {
    expect(
      _event(startsAt).eventDateReached(DateTime.utc(2026, 9, 30, 16)),
      isFalse,
    );
  });

  test('pagi hari-H sudah hadir walau jam mulai masih nanti', () {
    expect(
      _event(startsAt).eventDateReached(DateTime.utc(2026, 10, 1, 1)),
      isTrue,
    );
  });

  test('sehari sesudah', () {
    expect(
      _event(startsAt).eventDateReached(DateTime.utc(2026, 10, 2)),
      isTrue,
    );
  });

  test('startsAt null = belum', () {
    expect(_event(null).eventDateReached(DateTime.utc(2026, 10, 1, 1)), isFalse);
  });
}
