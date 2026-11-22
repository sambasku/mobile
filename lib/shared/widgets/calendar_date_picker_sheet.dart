import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Bottom sheet kalender Forui - pola sama form acara.
Future<DateTime?> showCalendarDatePickerSheet(
  BuildContext context, {
  required String title,
  DateTime? initial,
  DateTime? minDate,
  DateTime? maxDate,
}) {
  final selectionController = FDateSelectionController.single(
    initial: initial,
    toggleable: false,
  );
  bool selectable(DateTime date) {
    if (minDate != null && date.isBefore(_dateOnly(minDate))) return false;
    if (maxDate != null && date.isAfter(_dateOnly(maxDate))) return false;
    return true;
  }

  return showModalBottomSheet<DateTime?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: sheetContext.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),
            FCalendar.grid(
              selectionControl: FDateSelectionControl.managedSingle(
                controller: selectionController,
              ),
              control: FGridCalendarControl(selectable: selectable),
            ),
            const Gap(12),
            FButton(
              onPress: () =>
                  Navigator.of(sheetContext).pop(selectionController.value),
              child: Text(AppLocalizations.of(sheetContext).eventPickDate),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(selectionController.dispose);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);