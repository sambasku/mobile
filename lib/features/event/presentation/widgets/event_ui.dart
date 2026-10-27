import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../../../../l10n/app_localizations.dart';

/// Badge status pelaksanaan acara.
FBadge eventOccurrenceBadge(
  AppLocalizations l10n,
  EventOccurrenceStatus status,
) {
  final (variant, label) = switch (status) {
    EventOccurrenceStatus.upcoming => (
      FBadgeVariant.primary,
      l10n.eventChipUpcoming,
    ),
    EventOccurrenceStatus.ongoing => (
      FBadgeVariant.secondary,
      l10n.eventChipOngoing,
    ),
    EventOccurrenceStatus.completed => (
      FBadgeVariant.outline,
      l10n.eventChipEnded,
    ),
    EventOccurrenceStatus.cancelled => (
      FBadgeVariant.destructive,
      l10n.eventChipCancelled,
    ),
  };
  return FBadge(variant: variant, child: Text(label));
}

/// Format jadwal acara: `17 Nov 2026 21:00 - 23:00`.
///
/// Tanggal sama = jam saja di bagian kedua.
String formatEventSchedule(Event event) {
  final start = formatDateTime(event.startsAt);
  final end = formatDateTime(event.endsAt);
  if (start.isEmpty) return '';
  if (end.isEmpty || end == start) return start;
  final sameDay =
      event.startsAt.toLocal().day == event.endsAt.toLocal().day &&
      event.startsAt.toLocal().month == event.endsAt.toLocal().month &&
      event.startsAt.toLocal().year == event.endsAt.toLocal().year;
  if (sameDay) {
    final timeOnly = end.split(' ').last;
    return '$start - $timeOnly';
  }
  return '$start - $end';
}

/// Baris meta singkat: kategori, desa, jadwal.
List<String> eventMetaLines(Event event) {
  final out = <String>[];
  final category = event.category?.name;
  if (category != null && category.isNotEmpty) out.add(category);
  final village = event.village?.name;
  if (village != null && village.isNotEmpty) out.add(village);
  final schedule = formatEventSchedule(event);
  if (schedule.isNotEmpty) out.add(schedule);
  return out;
}

/// Baris meta yang ditampilkan di tile daftar acara.
String eventMetaLine(Event event) => eventMetaLines(event).join(' · ');

/// Section "Agenda terkait" - daftar mini acara untuk tempat wisata/desa.
///
/// Padding horizontal diserahkan pemanggil (halaman beda gutter). Kalau
/// events kosong, return null supaya section kosong tidak dirender.
Widget? buildEventMiniList(
  BuildContext context,
  List<Event> events, {
  required String title,
}) {
  if (events.isEmpty) return null;
  final theme = context.theme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Gap(20),
      Text(
        title,
        style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
      ),
      const Gap(8),
      for (final event in events) ...[
        EventMiniTile(event: event),
        const Gap(8),
      ],
    ],
  );
}

/// Tile ringkas acara (dipakai di section agenda). Tap = detail acara.
class EventMiniTile extends StatelessWidget {
  const EventMiniTile({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final schedule = formatEventSchedule(event);
    final place = event.locationText;
    return FTile(
      prefix: Icon(FLucideIcons.calendarDays, color: theme.colors.primary),
      title: Text(
        event.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (schedule.isNotEmpty) schedule,
          if (place.isNotEmpty) place,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: eventOccurrenceBadge(AppLocalizations.of(context), event.effectiveOccurrenceStatus),
      onPress: onTap ?? () => context.push(EventRouter.detailPath(event.slug)),
    );
  }
}
