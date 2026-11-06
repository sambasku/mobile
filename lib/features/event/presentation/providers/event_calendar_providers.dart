import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/event_remote_datasource.dart';
import '../../domain/entities/event.dart';
import '../../domain/event_calendar.dart';
import 'event_providers.dart';

/// Hasil fetch satu bulan: item + set tanggal WIB yang punya acara.
class EventCalendarMonthState {
  const EventCalendarMonthState({
    this.items = const [],
    this.dateKeys = const {},
  });

  final List<Event> items;
  final Set<String> dateKeys;

  List<Event> eventsOnDay(DateTime cellUtc) {
    final dayEvents = items
        .where((e) => eventOverlapsCalendarDay(e, cellUtc))
        .toList();
    dayEvents.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return dayEvents;
  }
}

final eventCalendarMonthProvider = FutureProvider.autoDispose
    .family<EventCalendarMonthState, EventCalendarMonth>((ref, month) async {
      final bounds = eventCalendarMonthBoundsWib(month);
      final repo = ref.watch(eventRepositoryProvider);
      final collected = <Event>[];
      String? before;
      var pages = 0;
      while (pages < eventsMaxPages) {
        pages++;
        final page = await repo.listPage(
          limit: 500,
          before: before,
          overlapsFrom: bounds.from,
          overlapsTo: bounds.to,
        );
        if (!ref.mounted) {
          return EventCalendarMonthState(
            items: collected,
            dateKeys: _dateKeysOf(collected),
          );
        }
        final seen = collected.map((e) => e.id).toSet();
        for (final e in page.events) {
          if (seen.add(e.id)) collected.add(e);
        }
        final cursor = page.nextCursor;
        if (cursor == null || cursor.isEmpty || page.events.isEmpty) break;
        before = cursor;
      }
      return EventCalendarMonthState(
        items: collected,
        dateKeys: _dateKeysOf(collected),
      );
    });

Set<String> _dateKeysOf(List<Event> items) {
  final keys = <String>{};
  for (final e in items) {
    keys.addAll(eventCalendarDateKeysForEvent(e));
  }
  return keys;
}
