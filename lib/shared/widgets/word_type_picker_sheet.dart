import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../domain/word_type_options.dart';

/// Bottom sheet jenis entri. Teks [detail] boleh panjang dan menggulir.
Future<String?> showWordTypePickerSheet(
  BuildContext context, {
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _WordTypePickerSheetBody(selected: selected);
    },
  );
}

class _WordTypePickerSheetBody extends StatelessWidget {
  const _WordTypePickerSheetBody({required this.selected});

  final String selected;

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * 0.65;
    return target.clamp(280.0, available);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: _sheetHeight(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(FLucideIcons.tags, size: 18, color: theme.colors.primary),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Pilih jenis entri',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Ketuk untuk memilih',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
              children: [
                for (final option in wordTypeOptions)
                  // InkWell butuh Material. Bukan FTile: subtitle FTile terpotong,
                  // padahal penjelasan jenis entri boleh panjang.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(option.value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: theme.typography.sm.copyWith(
                                      fontWeight: option.value == selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: option.value == selected
                                          ? theme.colors.primary
                                          : theme.colors.foreground,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    option.detail,
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (option.value == selected)
                              Icon(
                                FLucideIcons.check,
                                size: 18,
                                color: theme.colors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
