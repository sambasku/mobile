import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Bottom sheet error form-level (submit gagal) atau error muat data.
///
/// Jangan pakai untuk `RATE_LIMITED` (toast) atau validasi per-field (inline).
/// Lihat Pola baku error sheet.
///
/// `onRetry` opsional: kalau diisi, sheet menampilkan "Coba lagi" di samping
/// "Mengerti" supaya user tidak perlu menutup sheet lalu menekan tombol lain.
Future<void> showAppErrorSheet(
  BuildContext context, {
  required String message,
  String title = 'Terjadi kesalahan',
  VoidCallback? onRetry,
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
                  style: theme.typography.body.lg.copyWith(fontWeight: .w600),
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
                if (onRetry == null)
                  FButton(
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Mengerti'),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Tutup'),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: FButton(
                          onPress: () {
                            Navigator.of(sheetContext).pop();
                            onRetry();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
