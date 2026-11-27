import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../domain/entities/word_summary.dart';

class LemmaMergeSheetResult {
  const LemmaMergeSheetResult({required this.keepWordId, this.reasonText});

  final String keepWordId;
  final String? reasonText;
}

/// Bottom sheet: pilih lemma utama.
Future<LemmaMergeSheetResult?> showLemmaMergeSubmitSheet(
  BuildContext context, {
  required List<WordSummary> items,
  required bool requireReason,
}) {
  return showModalBottomSheet<LemmaMergeSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: MediaQuery.viewInsetsOf(ctx),
      child: _LemmaMergeSubmitSheet(
        items: items,
        requireReason: requireReason,
      ),
    ),
  );
}

class _LemmaMergeSubmitSheet extends HookConsumerWidget {
  const _LemmaMergeSubmitSheet({
    required this.items,
    required this.requireReason,
  });

  final List<WordSummary> items;
  final bool requireReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final keepId = useState(items.first.id);
    final reason = useTextEditingController();
    final busy = useState(false);

    return FScaffold(
      childPad: true,
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: busy.value
                ? null
                : () {
                    if (requireReason && reason.text.trim().length < 10) {
                      showFToast(
                        context: context,
                        title: Text(l10n.lemmaMergeReasonTooShort),
                      );
                      return;
                    }
                    Navigator.of(context).pop(
                      LemmaMergeSheetResult(
                        keepWordId: keepId.value,
                        reasonText: requireReason ? reason.text.trim() : null,
                      ),
                    );
                  },
            prefix: busy.value ? const FCircularProgress(size: .sm) : null,
            child: Text(l10n.lemmaMergeSubmit),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.lemmaMergeSheetTitle,
            style: context.theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lemmaMergePickPrimary,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          FTileGroup(
            children: [
              for (final w in items)
                FTile(
                  suffix: keepId.value == w.id
                      ? Icon(FLucideIcons.check, color: context.theme.colors.primary)
                      : null,
                  title: Text(w.lemma),
                  onPress: () => keepId.value = w.id,
                ),
            ],
          ),
          if (requireReason) ...[
            const SizedBox(height: 12),
            FTextField(
              control: FTextFieldControl.managed(controller: reason),
              hint: l10n.lemmaMergeReasonHint,
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}