import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// Pesan sederhana (judul + isi + tombol) sebagai bottom sheet, seragam
/// dengan `showAppErrorSheet` / `showAppInfoSheet`. Nama `Dialog` dipertahankan
/// supaya caller lama tidak perlu diubah.
///
/// [actions] menerima BuildContext sheet supaya tombol bisa
/// `Navigator.of(dialogContext).pop(...)`; ditumpuk vertikal, tombol pertama
/// = aksi utama. [barrierDismissible] false = tap luar, drag, dan tombol
/// kembali tidak menutup sheet (hanya lewat salah satu tombol aksi).
///
/// Radius/clip sheet datang dari tema (`_materialTheme` di app.dart).
Future<T?> showFMessageDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget body,
  required List<Widget> Function(BuildContext dialogContext) actions,
  bool barrierDismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: barrierDismissible,
  enableDrag: barrierDismissible,
  builder: (sheetContext) {
    final theme = sheetContext.theme;
    final buttons = actions(sheetContext);
    return PopScope(
      canPop: barrierDismissible,
      child: Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            // Keyboard (body berisi FTextField di sheet "Tolak usulan")
            // mendorong sheet naik, bukan menutupi input.
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DefaultTextStyle(
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                  child: title,
                ),
                const Gap(8),
                Flexible(
                  child: SingleChildScrollView(
                    child: DefaultTextStyle(
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      child: body,
                    ),
                  ),
                ),
                const Gap(16),
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const Gap(8),
                  buttons[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  },
);
