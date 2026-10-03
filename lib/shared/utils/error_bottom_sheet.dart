import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Bottom sheet error form-level (submit gagal).
///
/// Jangan pakai untuk `RATE_LIMITED` (toast), validasi per-field (inline),
/// atau empty/load list (FAlert di body). Lihat
/// Pola baku error sheet.
Future<void> showAppErrorSheet(
  BuildContext context, {
  required String message,
  String title = 'Terjadi kesalahan',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: theme.typography.lg.copyWith(fontWeight: .w600),
                ),
                const Gap(8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                FButton(
                  onPress: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
