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
                      suffix: FButton(
                        onPress: () async {
                          Navigator.of(sheetContext).pop();
                          await callLayananPhone(phone.phone);
                        },
                        child: Text(l10n.layananCall),
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

String layananPhonesSubtitle(AppLocalizations l10n, List<LayananPhone> phones) {
  if (phones.isEmpty) return l10n.layananCategoryEmpty;
  if (phones.length == 1) {
    final p = phones.first;
    final note = (p.note ?? '').trim();
    return note.isEmpty ? p.phone : '${p.phone} · $note';
  }
  final first = phones.first;
  final note = (first.note ?? '').trim();
  final head = note.isEmpty ? first.phone : '${first.phone} · $note';
  return '$head · ${l10n.layananPhoneCount(phones.length)}';
}
