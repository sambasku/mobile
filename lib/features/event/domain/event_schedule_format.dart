import 'package:forui/forui.dart';

import '../../../core/utils/format_datetime.dart';
import '../../../l10n/app_localizations.dart';
import 'entities/event.dart';
import 'event_contribute_schedule.dart';

bool eventDateTimeTimeUnknown(DateTime dt) {
  final local = dt.toLocal();
  return local.hour == 0 && local.minute == 0;
}

String formatScheduleDatePart(DateTime date, FTime? time) {
  if (time == null) {
    return formatDateShort(DateTime(date.year, date.month, date.day));
  }
  final combined = combineEventDateTime(date, time);
  return formatDateTime(combined!);
}

String formatScheduleFromStored(DateTime dt) {
  if (eventDateTimeTimeUnknown(dt)) return formatDateShort(dt);
  return formatDateTime(dt);
}

String eventScheduleRangeText(
  AppLocalizations l10n,
  String start,
  String end,
) =>
    l10n.eventScheduleRange(start, end);

/// Pratinjau jadwal di form usulan; jam mulai dan selesai boleh null.
String formatEventContributeSchedulePreview(
  AppLocalizations l10n, {
  required DateTime? startDate,
  required FTime? startTime,
  required DateTime? endDate,
  required FTime? endTime,
}) {
  if (startDate == null) return '';
  final start = formatScheduleDatePart(startDate, startTime);
  if (endDate == null) {
    return l10n.eventFormSchedulePreview(start);
  }
  final end = formatScheduleDatePart(endDate, endTime);
  final sameDay = eventDateOnly(startDate) == eventDateOnly(endDate);
  if (sameDay && startTime != null && endTime != null) {
    return l10n.eventFormSchedulePreview('$start - $endTime');
  }
  if (sameDay && endTime == null) {
    return l10n.eventFormSchedulePreview(start);
  }
  return l10n.eventFormSchedulePreview(
    eventScheduleRangeText(l10n, start, end),
  );
}

/// Format jadwal acara untuk list/detail (midnight = jam tidak diketahui).
String formatEventSchedule(AppLocalizations l10n, Event event) {
  final startAt = event.startsAt;
  if (startAt == null) return '';
  final start = formatScheduleFromStored(startAt);
  final endAt = event.endsAt;
  if (endAt == null) return start;
  final end = formatScheduleFromStored(endAt);
  if (end.isEmpty || end == start) return start;

  final startLocal = startAt.toLocal();
  final endLocal = endAt.toLocal();
  final sameDay =
      startLocal.year == endLocal.year &&
      startLocal.month == endLocal.month &&
      startLocal.day == endLocal.day;

  final startTimeKnown = !eventDateTimeTimeUnknown(startAt);
  final endTimeKnown = !eventDateTimeTimeUnknown(endAt);

  if (sameDay && startTimeKnown && endTimeKnown) {
    final timeOnly = end.split(' ').last;
    return '$start - $timeOnly';
  }
  if (sameDay && !endTimeKnown) return start;

  return eventScheduleRangeText(l10n, start, end);
}