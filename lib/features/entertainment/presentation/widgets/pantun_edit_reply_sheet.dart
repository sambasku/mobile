import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../domain/rhyme_check.dart';

class PantunReplyEditRevision {
  const PantunReplyEditRevision({
    required this.lines,
    required this.rhymeScheme,
    required this.createdAt,
  });

  final List<String> lines;
  final String rhymeScheme;
  final String createdAt;
}

class PantunReplyEditHistory {
  const PantunReplyEditHistory({
    required this.currentLines,
    required this.currentRhymeScheme,
    required this.revisions,
  });

  final List<String> currentLines;
  final String currentRhymeScheme;
  final List<PantunReplyEditRevision> revisions;
}

Future<void> showPantunReplyEditHistorySheet(
  BuildContext context, {
  required String title,
  required PantunReplyEditHistory history,
}) {
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final items = history.revisions;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  title,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    l10n.threadEditHistoryEmpty,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: FTileGroup(
                      children: [
                        for (final rev in items)
                          FTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final line in rev.lines)
                                  Text(
                                    line,
                                    style: theme.typography.body.sm,
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              () {
                                final label = formatRelativeCompact(
                                  DateTime.tryParse(rev.createdAt),
                                );
                                return label.isEmpty
                                    ? l10n.threadEditHistoryUnknownTime
                                    : label;
                              }(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.commonClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<List<String>?> showPantunReplyEditSheet(
  BuildContext context, {
  required List<String> initialLines,
  required Future<String?> Function(List<String> lines, String? scheme) onSave,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<List<String>?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final controllers = List.generate(
        4,
        (i) => TextEditingController(
          text: i < initialLines.length ? initialLines[i] : '',
        ),
      );
      var submitting = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final lines = controllers.map((c) => c.text.trim()).toList();
          final allFilled = lines.every((l) => l.isNotEmpty);
          final scheme = allFilled ? pickRhymeScheme(lines) : null;
          final canSubmit = scheme != null && !submitting;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    l10n.pantunReplyEditTitle,
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: controllers[i],
                          ),
                          hint: switch (i) {
                            0 => l10n.pantunReplyEditLine1,
                            1 => l10n.pantunReplyEditLine2,
                            2 => l10n.pantunReplyEditLine3,
                            _ => l10n.pantunReplyEditLine4,
                          },
                          enabled: !submitting,
                          textInputAction: i < 3
                              ? TextInputAction.next
                              : TextInputAction.done,
                        ),
                        if (i < 3) const Gap(8),
                      ],
                    ],
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FButton(
                    onPress: canSubmit
                        ? () async {
                            setState(() => submitting = true);
                            final err = await onSave(lines, scheme);
                            if (!sheetContext.mounted) return;
                            if (err == null) {
                              Navigator.of(sheetContext).pop(lines);
                              return;
                            }
                            setState(() => submitting = false);
                            await showAppErrorSheet(
                              sheetContext,
                              message: err,
                            );
                          }
                        : null,
                    prefix: submitting
                        ? const FCircularProgress(size: .sm)
                        : null,
                    child: Text(l10n.pantunReplyEditSave),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
