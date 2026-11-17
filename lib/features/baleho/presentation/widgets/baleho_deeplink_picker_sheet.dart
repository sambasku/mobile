import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import 'baleho_entity_search_sheet.dart';

const _kSearchUsaha = '__baleho_search_usaha__';
const _kSearchAcara = '__baleho_search_acara__';
const _kSearchWisata = '__baleho_search_wisata__';

/// Pilihan deeplink awam. Untuk usaha/acara/wisata → sheet pencarian entity.
Future<String?> showBalehoDeeplinkPickerSheet(
  BuildContext context, {
  String? selectedPath,
}) async {
  final l10n = AppLocalizations.of(context);
  final selected = selectedPath?.trim() ?? '';
  final items = <OptionPickerItem<String>>[
    OptionPickerItem(
      value: '/',
      label: 'Beranda',
      detail: '/',
      selected: selected == '/',
    ),
    OptionPickerItem(
      value: '/explore',
      label: 'Eksplorasi',
      detail: '/explore',
      selected: selected == '/explore',
    ),
    OptionPickerItem(
      value: '/usaha',
      label: 'Daftar usaha',
      detail: '/usaha',
      selected: selected == '/usaha',
    ),
    OptionPickerItem(
      value: _kSearchUsaha,
      label: l10n.balehoDeeplinkPickUsaha,
      detail: l10n.balehoDeeplinkPickUsahaDetail,
      selected: selected.startsWith('/usaha/') && selected != '/usaha/',
    ),
    OptionPickerItem(
      value: _kSearchWisata,
      label: l10n.balehoDeeplinkPickWisata,
      detail: l10n.balehoDeeplinkPickWisataDetail,
      selected: selected.startsWith('/explore/place/'),
    ),
    OptionPickerItem(
      value: '/acara',
      label: 'Daftar acara',
      detail: '/acara',
      selected: selected == '/acara',
    ),
    OptionPickerItem(
      value: _kSearchAcara,
      label: l10n.balehoDeeplinkPickAcara,
      detail: l10n.balehoDeeplinkPickAcaraDetail,
      selected: selected.startsWith('/acara/') && selected != '/acara/',
    ),
    OptionPickerItem(
      value: '/karya/',
      label: 'Detail karya',
      detail: 'Lengkapi slug: /karya/nama-karya',
      selected: selected.startsWith('/karya/'),
    ),
    OptionPickerItem(
      value: '/layanan/',
      label: 'Detail layanan',
      detail: 'Lengkapi slug: /layanan/nama-layanan',
      selected: selected.startsWith('/layanan/'),
    ),
    OptionPickerItem(
      value: '/encyclopedia',
      label: 'Ensiklopedia',
      detail: '/encyclopedia',
      selected: selected == '/encyclopedia',
    ),
    OptionPickerItem(
      value: '/encyclopedia/',
      label: 'Artikel ensiklopedia',
      detail: 'Lengkapi slug: /encyclopedia/judul',
      selected: selected.startsWith('/encyclopedia/') &&
          selected != '/encyclopedia/',
    ),
    OptionPickerItem(
      value: '/words',
      label: 'Kamus',
      detail: '/words',
      selected: selected == '/words',
    ),
    OptionPickerItem(
      value: '/baleho',
      label: 'Baleho',
      detail: '/baleho',
      selected: selected == '/baleho',
    ),
  ];

  final choice = await showOptionPickerSheet<String>(
    context,
    title: l10n.balehoDeeplinkPickerTitle,
    subtitle: l10n.balehoDeeplinkPickerSubtitle,
    icon: FLucideIcons.link,
    searchable: true,
    searchHint: l10n.balehoDeeplinkPickCta,
    items: items,
  );
  if (choice == null || !context.mounted) return null;

  final kind = switch (choice) {
    _kSearchUsaha => BalehoEntitySearchKind.usaha,
    _kSearchAcara => BalehoEntitySearchKind.acara,
    _kSearchWisata => BalehoEntitySearchKind.wisata,
    _ => null,
  };
  if (kind != null) {
    return showBalehoEntitySearchSheet(context, kind: kind);
  }
  return choice;
}
