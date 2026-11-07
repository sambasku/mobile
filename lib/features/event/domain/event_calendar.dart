import 'entities/event.dart';

/// Offset WIB tetap (UTC+7) untuk bound kalender & hari lokal indikator.
const Duration eventCalendarWibOffset = Duration(hours: 7);

/// Kunci bulan kalender (`year` + `month` 1-12).
class EventCalendarMonth {
  const EventCalendarMonth(this.year, this.month);

  final int year;
  final int month;

  @override
  bool operator ==(Object other) =>
      other is EventCalendarMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}';
}

/// Midnight WIB hari 1 bulan → UTC, sampai midnight WIB hari 1 bulan berikutnya.
({DateTime from, DateTime to}) eventCalendarMonthBoundsWib(
  EventCalendarMonth month,
) {
  final from = DateTime.utc(
    month.year,
    month.month,
    1,
  ).subtract(eventCalendarWibOffset);
  final next = month.month == 12
      ? DateTime.utc(month.year + 1, 1, 1)
      : DateTime.utc(month.year, month.month + 1, 1);
  final to = next.subtract(eventCalendarWibOffset);
  return (from: from, to: to);
}

/// Tanggal kalender WIB `YYYY-MM-DD` dari instant UTC.
String eventCalendarDateKeyWib(DateTime instant) {
  final wib = instant.toUtc().add(eventCalendarWibOffset);
  final y = wib.year.toString().padLeft(4, '0');
  final m = wib.month.toString().padLeft(2, '0');
  final d = wib.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Key dari sel [FCalendar] (UTC y-m-d = tanggal kalender yang ditampilkan).
String eventCalendarCellDateKey(DateTime cellUtc) {
  final y = cellUtc.year.toString().padLeft(4, '0');
  final m = cellUtc.month.toString().padLeft(2, '0');
  final d = cellUtc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Semua hari WIB yang overlap jadwal acara (inklusif).
Set<String> eventCalendarDateKeysForEvent(Event event) {
  final startKey = eventCalendarDateKeyWib(event.startsAt);
  final endKey = eventCalendarDateKeyWib(event.endsAt);
  final startWib = event.startsAt.toUtc().add(eventCalendarWibOffset);
  final endWib = event.endsAt.toUtc().add(eventCalendarWibOffset);
  var day = DateTime.utc(startWib.year, startWib.month, startWib.day);
  final last = DateTime.utc(endWib.year, endWib.month, endWib.day);
  final out = <String>{startKey, endKey};
  while (!day.isAfter(last)) {
    out.add(eventCalendarCellDateKey(day));
    day = day.add(const Duration(days: 1));
  }
  return out;
}

/// Apakah acara overlap satu hari kalender (y/m/d sel Forui = tanggal WIB).
bool eventOverlapsCalendarDay(Event event, DateTime cellUtc) {
  final dayStart = DateTime.utc(
    cellUtc.year,
    cellUtc.month,
    cellUtc.day,
  ).subtract(eventCalendarWibOffset);
  final dayEnd = dayStart.add(const Duration(days: 1));
  return event.startsAt.isBefore(dayEnd) && !event.endsAt.isBefore(dayStart);
}
