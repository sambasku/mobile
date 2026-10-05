import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../domain/sambas_map_config.dart';

/// Bottomsheet pilih basemap peta (Jalan/Satelit/Terain). Ganti tap-cycle:
/// user memilih langsung dari daftar, tak perlu menekan berulang.
/// Kembali `MapBasemap` terpilih, atau null bila ditutup tanpa pilih.
Future<MapBasemap?> showBasemapPickerSheet(
  BuildContext context, {
  required MapBasemap selected,
}) {
  return showModalBottomSheet<MapBasemap>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gaya peta',
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(12),
                FTileGroup(
                  children: [
                    for (final b in MapBasemap.values)
                      FTile(
                        title: Text(b.label),
                        subtitle: Text(
                          b.attribution.isEmpty
                              ? 'Gratis, tanpa API key'
                              : b.attribution.replaceAll('&copy;', '(c)'),
                        ),
                        prefix: Icon(switch (b) {
                          MapBasemap.street => FLucideIcons.map,
                          MapBasemap.satellite => FLucideIcons.satellite,
                          MapBasemap.terrain => FLucideIcons.mountain,
                        }, size: 18),
                        suffix: b == selected
                            ? const Icon(FLucideIcons.check, size: 18)
                            : null,
                        onPress: () =>
                            Navigator.of(sheetContext).pop<MapBasemap>(b),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
