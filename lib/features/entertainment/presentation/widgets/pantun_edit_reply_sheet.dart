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
  return showModalBottomSheet<List<String>?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _PantunReplyEditSheetBody(
      initialLines: initialLines,
      onSave: onSave,
    ),
  );
}

class _PantunReplyEditSheetBody extends StatefulWidget {
  const _PantunReplyEditSheetBody({
    required this.initialLines,
    required this.onSave,
  });

  final List<String> initialLines;
  final Future<String?> Function(List<String> lines, String? scheme) onSave;

  @override
  State<_PantunReplyEditSheetBody> createState() =>
      _PantunReplyEditSheetBodyState();
}

class _PantunReplyEditSheetBodyState extends State<_PantunReplyEditSheetBody> {
  late final List<TextEditingController> _controllers;
  var _submitting = false;

  void _onLineChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < widget.initialLines.length ? widget.initialLines[i] : '',
      )..addListener(_onLineChanged),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c
        ..removeListener(_onLineChanged)
        ..dispose();
    }
    super.dispose();
  }

  Future<void> _submit(List<String> lines, String scheme) async {
    setState(() => _submitting = true);
    final err = await widget.onSave(lines, scheme);
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop(lines);
      return;
    }
    setState(() => _submitting = false);
    await showAppErrorSheet(context, message: err);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final lines = _controllers.map((c) => c.text.trim()).toList();
    final allFilled = lines.every((l) => l.isNotEmpty);
    final scheme = allFilled ? pickRhymeScheme(lines) : null;
    final canSubmit = scheme != null && !_submitting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
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
                          controller: _controllers[i],
                        ),
                        hint: switch (i) {
                          0 => l10n.pantunReplyEditLine1,
                          1 => l10n.pantunReplyEditLine2,
                          2 => l10n.pantunReplyEditLine3,
                          _ => l10n.pantunReplyEditLine4,
                        },
                        enabled: !_submitting,
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
                  onPress: canSubmit ? () => _submit(lines, scheme) : null,
                  prefix: _submitting
                      ? const FCircularProgress(size: .sm)
                      : null,
                  child: Text(l10n.pantunReplyEditSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
