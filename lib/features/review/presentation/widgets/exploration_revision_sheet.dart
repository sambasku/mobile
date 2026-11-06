import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

Future<String?> showExplorationRevisionSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => const _ExplorationRevisionSheet(),
  );
}

class _ExplorationRevisionSheet extends StatefulWidget {
  const _ExplorationRevisionSheet();

  @override
  State<_ExplorationRevisionSheet> createState() =>
      _ExplorationRevisionSheetState();
}

class _ExplorationRevisionSheetState extends State<_ExplorationRevisionSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _controller.text.trim();
    if (note.length < 3) return;
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _controller.text.trim().length >= 3;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Gap(16),
            Text(
              l10n.reviewExploreRevisionSheetTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(4),
            Text(
              l10n.reviewExploreRevisionSheetBody,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _controller,
                onChange: (_) => setState(() {}),
              ),
              label: Text(l10n.reviewExploreRevisionNoteLabel),
              hint: l10n.reviewExploreRevisionNoteHint,
              maxLines: 4,
              autofocus: true,
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.pop(context),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: FButton(
                    onPress: canSubmit ? _submit : null,
                    child: Text(l10n.reviewExploreRevisionSubmit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
