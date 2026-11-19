import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet info (bukan error merah) - mis. akun OAuth tidak bisa
/// reset password / tooltip penjelasan. Pola sama dengan
/// `showAppErrorSheet`, hanya judul dan aksen berbeda.
///
/// Latar pakai [FColors.background] Forui (bukan M3 surfaceContainer*) supaya
/// light dan dark mode konsisten - Forui approximate Material sering tidak
/// set surfaceContainerLow (sheet putih di dark).
Future<void> showAppInfoSheet(
  BuildContext context, {
  required String message,
  String? title,
  /// Opsional: ikon/gambar di atas judul (mis. lencana achievement).
  Widget? leading,
}) {
  final theme = context.theme;
  final l10n = AppLocalizations.of(context);
  final sheetTitle = title ?? l10n.infoSheetTitle;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: theme.colors.background,
    builder: (sheetContext) {
      final sheetTheme = sheetContext.theme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null) ...[
                Center(child: leading),
                const Gap(12),
              ],
              Text(
                sheetTitle,
                textAlign: leading != null ? TextAlign.center : TextAlign.start,
                style: sheetTheme.typography.body.lg.copyWith(
                  fontWeight: .w600,
                  color: sheetTheme.colors.foreground,
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
                    textAlign:
                        leading != null ? TextAlign.center : TextAlign.start,
                    style: sheetTheme.typography.body.sm.copyWith(
                      color: sheetTheme.colors.mutedForeground,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              FButton(
                onPress: () => Navigator.of(sheetContext).pop(),
                child: Text(l10n.infoSheetUnderstood),
              ),
            ],
          ),
        ),
      );
    },
  );
}
