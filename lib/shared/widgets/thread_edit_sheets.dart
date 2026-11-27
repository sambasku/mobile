import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../core/utils/format_datetime.dart';
import '../../l10n/app_localizations.dart';
import '../utils/error_bottom_sheet.dart';

/// Satu revisi teks (komentar / balasan diskusi).
class ThreadTextEditRevision {
  const ThreadTextEditRevision({
    required this.body,
    required this.createdAt,
  });

  final String body;
  final String? createdAt;
}

/// Riwayat sunting teks dari GET edit-history.
class ThreadTextEditHistory {
  const ThreadTextEditHistory({
    required this.revisions,
    this.currentBody,
    this.currentUpdatedAt,
  });

  final String? currentBody;
  final String? currentUpdatedAt;
  final List<ThreadTextEditRevision> revisions;
}

String _formatRevisionTime(AppLocalizations l10n, String? createdAt) {
  final label = formatRelativeCompact(DateTime.tryParse(createdAt ?? ''));
  if (label.isEmpty) return l10n.threadEditHistoryUnknownTime;
  return label;
}

Future<void> showThreadTextEditHistorySheet(
  BuildContext context, {
  required String title,
  required ThreadTextEditHistory history,
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
                            title: Text(rev.body),
                            subtitle: Text(
                              _formatRevisionTime(
                                l10n,
                                rev.createdAt,
                              ),
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

/// Bottom sheet sunting teks (komentar / balasan diskusi).
Future<String?> showThreadTextEditSheet(
  BuildContext context, {
  required String title,
  required String initialBody,
  required String saveLabel,
  required Future<String?> Function(String body) onSave,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ThreadTextEditSheetBody(
      title: title,
      initialBody: initialBody,
      saveLabel: saveLabel,
      onSave: onSave,
    ),
  );
}

class _ThreadTextEditSheetBody extends StatefulWidget {
  const _ThreadTextEditSheetBody({
    required this.title,
    required this.initialBody,
    required this.saveLabel,
    required this.onSave,
  });

  final String title;
  final String initialBody;
  final String saveLabel;
  final Future<String?> Function(String body) onSave;

  @override
  State<_ThreadTextEditSheetBody> createState() =>
      _ThreadTextEditSheetBodyState();
}

class _ThreadTextEditSheetBodyState extends State<_ThreadTextEditSheetBody> {
  late final TextEditingController _controller;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final err = await widget.onSave(_controller.text.trim());
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop(_controller.text);
      return;
    }
    setState(() => _submitting = false);
    await showAppErrorSheet(context, message: err);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                widget.title,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FTextField(
                control: FTextFieldControl.managed(controller: _controller),
                enabled: !_submitting,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                minLines: 3,
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FButton(
                onPress: _submitting ? null : _submit,
                prefix: _submitting
                    ? const FCircularProgress(size: .sm)
                    : null,
                child: Text(widget.saveLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
