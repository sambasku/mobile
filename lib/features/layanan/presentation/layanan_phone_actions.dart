import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/layanan.dart';

Future<void> callLayananPhone(String phone) {
  return launchUrl(Uri(scheme: 'tel', path: phone));
}

/// Satu nomor → langsung telepon. Banyak → sheet pilih (judul = note/shift).
Future<void> callOrPickLayananPhones(
  BuildContext context, {
  required List<LayananPhone> phones,
}) async {
  if (phones.isEmpty) return;
  if (phones.length == 1) {
    await callLayananPhone(phones.first.phone);
    return;
  }
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTileGroup(
                label: Text(l10n.layananPickPhone),
                children: [
                  for (final phone in phones)
                    FTile(
                      title: Text(phone.phone),
                      subtitle: Text(
                        (phone.note ?? '').isEmpty
                            ? l10n.layananCall
                            : phone.note!,
                      ),
                      suffix: Icon(
                        FLucideIcons.chevronRight,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                      onPress: () async {
                        Navigator.of(sheetContext).pop();
                        await callLayananPhone(phone.phone);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
