import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import 'event_ui.dart';

/// Bottomsheet daftar acara di satu tanggal. Return path detail (pop-then-push).
Future<void> showEventDaySheet(
  BuildContext context, {
  required DateTime day,
  required List<Event> events,
}) async {
  final path = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      var handled = false;
      void go(String next) {
        if (handled) return;
        handled = true;
        Navigator.of(sheetContext).pop(next);
      }

      final title = l10n.eventDaySheetTitle(_formatDayTitle(day));
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: 12 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: sheetContext.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.eventDaySheetEmpty,
                    textAlign: TextAlign.center,
                    style: sheetContext.theme.typography.body.sm.copyWith(
                      color: sheetContext.theme.colors.mutedForeground,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(sheetContext).height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const Gap(8),
                    itemBuilder: (context, i) {
                      final event = events[i];
                      return FTile(
                        title: Text(event.name),
                        subtitle: Text(
                          [
                            formatEventSchedule(event),
                            if (event.locationText.isNotEmpty)
                              event.locationText,
                          ].where((s) => s.isNotEmpty).join(' · '),
                        ),
                        onPress: () => go(EventRouter.detailPath(event.slug)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
  if (path != null && context.mounted) {
    context.push(path);
  }
}

String _formatDayTitle(DateTime day) => formatDateShort(
      DateTime(day.year, day.month, day.day),
    );
