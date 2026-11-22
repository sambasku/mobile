import 'package:forui/forui.dart';

DateTime eventDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Tanggal kalender + jam opsional → datetime lokal (jam null = 00:00).
DateTime? combineEventDateTime(DateTime? date, FTime? time) {
  if (date == null) return null;
  final hour = time?.hour ?? 0;
  final minute = time?.minute ?? 0;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

/// True bila tanggal/jam selesai sebelum mulai (validasi client sebelum submit).
bool eventScheduleOrderingInvalid({
  required DateTime startDate,
  required DateTime? endDate,
  required FTime? endTime,
  required DateTime startsAt,
  required DateTime? endsAt,
}) {
  if (endDate == null || endsAt == null) return false;
  if (endTime == null) {
    return eventDateOnly(endDate).isBefore(eventDateOnly(startDate));
  }
  return endsAt.isBefore(startsAt);
}