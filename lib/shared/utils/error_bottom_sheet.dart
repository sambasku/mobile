import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import '../../l10n/app_localizations.dart';

/// Bottom sheet error form-level (submit gagal) atau error muat data.
///
/// Jangan pakai untuk `RATE_LIMITED` (toast) atau validasi per-field (inline).
/// Lihat Pola baku error sheet.
///
/// `onRetry` opsional: kalau diisi, sheet menampilkan "Coba lagi" di samping
/// "Mengerti" supaya user tidak perlu menutup sheet lalu menekan tombol lain.
///
/// Satu sheet aktif per app (#316): panggilan berikutnya menunggu sheet yang
/// sama selesai, bukan menumpuk modal.
Future<void>? _activeAppErrorSheet;

Future<void> showAppErrorSheet(
  BuildContext context, {
  required String message,
  String? title,
  VoidCallback? onRetry,
}) {
  final inFlight = _activeAppErrorSheet;
  if (inFlight != null) {
    return inFlight;
  }

  // useRootNavigator: barrier menutup seluruh layar (termasuk bottom nav
  // shell). Tanpa ini, sheet dari tab nested hanya dim di area navigator tab.
  late final Future<void> future;
  future = showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
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
                  title ?? AppLocalizations.of(sheetContext).errorSheetTitle,
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
                    child: Text(AppLocalizations.of(sheetContext).errorSheetOk),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () => Navigator.of(sheetContext).pop(),
                          child: Text(AppLocalizations.of(sheetContext).errorSheetClose),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: FButton(
                          onPress: () {
                            Navigator.of(sheetContext).pop();
                            onRetry();
                          },
                          child: Text(AppLocalizations.of(sheetContext).errorSheetRetry),
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
  ).whenComplete(() {
    if (identical(_activeAppErrorSheet, future)) {
      _activeAppErrorSheet = null;
    }
  });
  _activeAppErrorSheet = future;
  return future;
}
