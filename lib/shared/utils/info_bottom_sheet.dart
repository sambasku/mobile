import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Bottom sheet info (bukan error merah) - mis. akun OAuth tidak bisa
/// reset password. Pola sama dengan `showAppErrorSheet`, hanya judul
/// dan aksen berbeda supaya user tidak merasa gagal.
Future<void> showAppInfoSheet(
  BuildContext context, {
  required String message,
  String title = 'Informasi',
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
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: .w600,
                    color: theme.colors.primary,
                  ),
                ),
                const Gap(8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: theme.typography.body.sm.copyWith(
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
