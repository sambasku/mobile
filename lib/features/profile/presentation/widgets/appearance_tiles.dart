import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/forui_palette_controller.dart';
import '../../../../core/theme/forui_palettes.dart';
import '../../../../core/theme/font_scale_controller.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../l10n/app_localizations.dart';

/// Menu Tampilan di tab profil: mode light/dark/sistem + palet warna forui.
/// CATATAN: fungsi (bukan widget) agar hasilnya FTileMixin → bisa jadi child FTileGroup;
/// ref.watch di sini dipanggil saat build si pemanggil, jadi tetap reaktif.
/// CATATAN: wajib managedRadio (bukan lifted) - lifted itu multi-select,
/// tap item baru menghasilkan set {lama, baru} → .first malah nilai lama.

Map<ThemeMode, String> _modeLabels(AppLocalizations l10n) => {
  ThemeMode.system: l10n.appearanceThemeSystem,
  ThemeMode.light: l10n.appearanceThemeLight,
  ThemeMode.dark: l10n.appearanceThemeDark,
};

FTileMixin themeModeTile(WidgetRef ref) {
  final l10n = AppLocalizations.of(ref.context);
  final labels = _modeLabels(l10n);
  final mode = ref.watch(themeModeControllerProvider);

  return FSelectMenuTile<ThemeMode>(
    prefix: const Icon(FLucideIcons.contrast),
    title: Text(l10n.appearanceThemeMode),
    details: Text(labels[mode] ?? ''),
    selectControl: FMultiValueControl.managedRadio(
      initial: mode,
      onChange: (values) {
        if (values.length == 1) {
          ref.read(themeModeControllerProvider.notifier).set(values.first);
        }
      },
    ),
    menu: [
      for (final entry in labels.entries)
        FSelectTile(value: entry.key, title: Text(entry.value)),
    ],
  );
}

FTileMixin paletteTile(WidgetRef ref) {
  final l10n = AppLocalizations.of(ref.context);
  final name = ref.watch(foruiPaletteControllerProvider);
  // 10 palet × ~56 px ≈ 560. Cap 320 (viewport tes 800×600 → 0.4×600=240)
  // hanya memuat Netral…Hijau; "Merah" tidak ter-layout.
  final menuMaxHeight = math.max(
    560.0,
    MediaQuery.sizeOf(ref.context).height * 0.4,
  );

  return FSelectMenuTile<String>(
    prefix: const Icon(FLucideIcons.palette),
    title: Text(l10n.appearancePalette),
    details: Text(foruiPaletteLabel(l10n, name)),
    maxHeight: menuMaxHeight,
    selectControl: FMultiValueControl.managedRadio(
      initial: name,
      onChange: (values) {
        if (values.length == 1) {
          ref.read(foruiPaletteControllerProvider.notifier).set(values.first);
        }
      },
    ),
    menu: [
      for (final entry in foruiPalettes.entries)
        FSelectTile(
          value: entry.key,
          title: Text(foruiPaletteLabel(l10n, entry.key)),
          details: _PaletteDot(color: entry.value.light.touch.colors.primary),
        ),
    ],
  );
}

Map<double, String> _scaleLabels(AppLocalizations l10n) => {
  0.85: l10n.appearanceScaleSmall,
  1.0: l10n.appearanceScaleNormal,
  1.15: l10n.appearanceScaleLarge,
  1.3: l10n.appearanceScaleHuge,
};

FTileMixin fontScaleTile(WidgetRef ref) {
  final l10n = AppLocalizations.of(ref.context);
  final scaleLabels = _scaleLabels(l10n);
  final scale = ref.watch(fontScaleControllerProvider);

  return FSelectMenuTile<double>(
    prefix: const Icon(FLucideIcons.aLargeSmall),
    title: Text(l10n.appearanceFontScale),
    details: Text(scaleLabels[scale] ?? l10n.appearanceScaleNormal),
    selectControl: FMultiValueControl.managedRadio(
      initial: scale,
      onChange: (values) {
        if (values.length == 1) {
          ref.read(fontScaleControllerProvider.notifier).set(values.first);
        }
      },
    ),
    menu: [
      for (final entry in scaleLabels.entries)
        FSelectTile(
          value: entry.key,
          title: Text(entry.value, style: TextStyle(fontSize: 14 * entry.key)),
        ),
    ],
  );
}

class _PaletteDot extends StatelessWidget {
  const _PaletteDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: context.theme.colors.border),
    ),
  );
}
