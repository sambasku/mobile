import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../domain/baleho_deeplink_pick.dart';
import 'baleho_entity_search_sheet.dart';

const _kSearchUsaha = '__baleho_search_usaha__';
const _kSearchAcara = '__baleho_search_acara__';
const _kSearchWisata = '__baleho_search_wisata__';
const _kSearchKarya = '__baleho_search_karya__';

/// Pilihan deeplink awam. Entity tertarget → sheet pencarian.
Future<BalehoDeeplinkPick?> showBalehoDeeplinkPickerSheet(
  BuildContext context, {
  String? selectedPath,
}) async {
  final l10n = AppLocalizations.of(context);
  final selected = selectedPath?.trim() ?? '';
  final items = <OptionPickerItem<String>>[
    OptionPickerItem(
      value: '/',
      label: l10n.balehoDeeplinkHome,
      detail: '/',
      selected: selected == '/',
    ),
    OptionPickerItem(
      value: '/explore',
      label: l10n.balehoDeeplinkExplore,
      detail: '/explore',
      selected: selected == '/explore',
    ),
    OptionPickerItem(
      value: '/usaha',
      label: l10n.balehoDeeplinkUsahaList,
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
      label: l10n.balehoDeeplinkAcaraList,
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
      value: _kSearchKarya,
      label: l10n.balehoDeeplinkPickKarya,
      detail: l10n.balehoDeeplinkPickKaryaDetail,
      selected: selected.startsWith('/karya/') && selected != '/karya/',
    ),
    OptionPickerItem(
      value: '/explore/ensiklopedia',
      label: l10n.balehoDeeplinkEncyclopedia,
      detail: '/explore/ensiklopedia',
      selected: selected == '/explore/ensiklopedia',
    ),
    OptionPickerItem(
      value: '/words',
      label: l10n.balehoDeeplinkWords,
      detail: '/words',
      selected: selected == '/words',
    ),
    OptionPickerItem(
      value: '/baleho',
      label: l10n.balehoDeeplinkBaleho,
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
    _kSearchKarya => BalehoEntitySearchKind.karya,
    _ => null,
  };
  if (kind != null) {
    return showBalehoEntitySearchSheet(context, kind: kind);
  }
  return BalehoDeeplinkPick(path: choice);
}
