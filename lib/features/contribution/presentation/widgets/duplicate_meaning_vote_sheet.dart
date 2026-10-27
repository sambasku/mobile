import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';

/// Hasil pilihan user di modal makna duplikat.
enum DuplicateMeaningVoteChoice {
  upvote,
  downvote,
  login,
}

/// Modal/bottom sheet: kata sudah ditemukan → pilih upvote/downvote (atau login).
Future<DuplicateMeaningVoteChoice?> showDuplicateMeaningVoteSheet({
  required BuildContext context,
  required String lemma,
  required bool isAuthenticated,
}) {
  return showModalBottomSheet<DuplicateMeaningVoteChoice>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = sheetContext.theme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.contributeDuplicateSheetTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                isAuthenticated
                    ? l10n.contributeDuplicateSheetBody(lemma)
                    : l10n.contributeDuplicateSheetGuestBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(20),
              if (!isAuthenticated)
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.login,
                  ),
                  child: Text(l10n.contributeDuplicateSheetLoginCta),
                )
              else ...[
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.upvote,
                  ),
                  child: Text(l10n.contributeDuplicateSheetSupport),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.downvote,
                  ),
                  child: Text(l10n.contributeDuplicateSheetOppose),
                ),
              ],
              const Gap(8),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(sheetContext).pop(),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      );
    },
  );
}
