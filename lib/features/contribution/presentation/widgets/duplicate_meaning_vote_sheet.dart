import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

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
      final theme = sheetContext.theme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kata ini sudah ditemukan',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                isAuthenticated
                    ? 'Pilih dukunganmu agar tercatat di riwayat perubahan $lemma.'
                    : 'Masuk dulu untuk mendukung atau menolak makna yang sudah ada.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(20),
              if (!isAuthenticated)
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.login,
                  ),
                  child: const Text('Masuk untuk mendukung'),
                )
              else ...[
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.upvote,
                  ),
                  child: const Text('Dukung makna ini'),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.of(sheetContext).pop(
                    DuplicateMeaningVoteChoice.downvote,
                  ),
                  child: const Text('Tidak mendukung'),
                ),
              ],
              const Gap(8),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(sheetContext).pop(),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
