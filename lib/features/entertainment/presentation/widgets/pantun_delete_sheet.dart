import 'package:material_ui/material_ui.dart' show Colors, showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Konfirmasi hapus pantun/balasan. true = user menekan Hapus.
///
/// Bottom sheet (bukan AlertDialog): konsisten dengan pola konfirmasi mobile
/// dan aman di pohon Forui tanpa ancestor Material.
Future<bool> showPantunDeleteSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    barrierColor: Colors.black54,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTileGroup(
            children: [
              FTile(title: Text(title), subtitle: Text(subtitle)),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  variant: FButtonVariant.destructive,
                  onPress: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Hapus'),
                ),
              ),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return confirmed == true;
}
