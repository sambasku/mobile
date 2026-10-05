import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/forui_palette_controller.dart';
import '../../../../core/theme/forui_palettes.dart';
import '../../../../core/theme/font_scale_controller.dart';
import '../../../../core/theme/theme_mode_controller.dart';

/// Menu Tampilan di tab profil: mode light/dark/sistem + palet warna forui.
/// CATATAN: fungsi (bukan widget) agar hasilnya FTileMixin → bisa jadi child FTileGroup;
/// ref.watch di sini dipanggil saat build si pemanggil, jadi tetap reaktif.
/// CATATAN: wajib managedRadio (bukan lifted) - lifted itu multi-select,
/// tap item baru menghasilkan set {lama, baru} → .first malah nilai lama.

const _modeLabels = {
  ThemeMode.system: 'Sistem',
  ThemeMode.light: 'Terang',
  ThemeMode.dark: 'Gelap',
};

FTileMixin themeModeTile(WidgetRef ref) {
  final mode = ref.watch(themeModeControllerProvider);

  return FSelectMenuTile<ThemeMode>(
    prefix: const Icon(FLucideIcons.contrast),
    title: const Text('Mode Tema'),
    details: Text(_modeLabels[mode] ?? ''),
    selectControl: FMultiValueControl.managedRadio(
      initial: mode,
      onChange: (values) {
        if (values.length == 1) {
          ref.read(themeModeControllerProvider.notifier).set(values.first);
        }
      },
    ),
    menu: [
      for (final entry in _modeLabels.entries)
        FSelectTile(value: entry.key, title: Text(entry.value)),
    ],
  );
}

FTileMixin paletteTile(WidgetRef ref) {
  final name = ref.watch(foruiPaletteControllerProvider);
  final palette = foruiPalettes[name] ?? foruiPalettes[defaultPalette]!;

  // 10 palet × ~56 px ≈ 560. Cap 320 (viewport tes 800×600 → 0.4×600=240)
  // hanya memuat Netral…Hijau; "Merah" tidak ter-layout.
  final menuMaxHeight = math.max(
    560.0,
    MediaQuery.sizeOf(ref.context).height * 0.4,
  );

  return FSelectMenuTile<String>(
    prefix: const Icon(FLucideIcons.palette),
    title: const Text('Warna Tema'),
    details: Text(palette.label),
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
          title: Text(entry.value.label),
          details: _PaletteDot(color: entry.value.light.touch.colors.primary),
        ),
    ],
  );
}

FTileMixin fontScaleTile(WidgetRef ref) {
  final scale = ref.watch(fontScaleControllerProvider);

  return FSelectMenuTile<double>(
    prefix: const Icon(FLucideIcons.aLargeSmall),
    title: const Text('Ukuran Teks'),
    details: Text(_scaleLabels[scale] ?? 'Normal'),
    selectControl: FMultiValueControl.managedRadio(
      initial: scale,
      onChange: (values) {
        if (values.length == 1) {
          ref.read(fontScaleControllerProvider.notifier).set(values.first);
        }
      },
    ),
    menu: [
      for (final entry in _scaleLabels.entries)
        FSelectTile(
          value: entry.key,
          title: Text(
            entry.value,
            style: TextStyle(fontSize: 14 * entry.key),
          ),
        ),
    ],
  );
}

final _scaleLabels = {
  0.85: 'Kecil',
  1.0: 'Normal',
  1.15: 'Besar',
  1.3: 'Sangat Besar',
};

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
