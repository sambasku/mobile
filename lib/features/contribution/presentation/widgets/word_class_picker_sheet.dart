import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

class WordClassPickItem {
  const WordClassPickItem({
    required this.id,
    required this.name,
    this.alias,
    this.code,
  });

  final String id;
  final String name;
  final String? alias;
  final String? code;

  String get displayLabel =>
      (alias == null || alias!.isEmpty || code == 'umum') ? name : '$name ($alias)';
}

/// Bottom sheet pilih kelas kata - list scrollable, aman untuk banyak opsi.
Future<WordClassPickItem?> showWordClassPickerSheet(
  BuildContext context, {
  required List<WordClassPickItem> items,
  String? selectedId,
}) {
  return showModalBottomSheet<WordClassPickItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _WordClassPickerSheetBody(items: items, selectedId: selectedId);
    },
  );
}

class _WordClassPickerSheetBody extends StatelessWidget {
  const _WordClassPickerSheetBody({
    required this.items,
    required this.selectedId,
  });

  final List<WordClassPickItem> items;
  final String? selectedId;

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * 0.65;
    return target.clamp(280.0, available);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final height = _sheetHeight(context);

    return SizedBox(
      height: height,
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
                    'Pilih kelas kata',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.lg.copyWith(
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
              '${items.length} pilihan - ketuk untuk memilih',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          if (_shortcuts(items) case final shortcuts when shortcuts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in shortcuts)
                    FButton(
                      variant: item.id == selectedId
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      size: FButtonSizeVariant.xs,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => Navigator.of(context).pop(item),
                      child: Text(_shortcutLabel(item)),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada kelas kata',
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = item.id == selectedId;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(item),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: theme.typography.body.sm.copyWith(
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? theme.colors.primary
                                              : theme.colors.foreground,
                                        ),
                                      ),
                                      if (item.alias != null &&
                                          item.alias!.isNotEmpty &&
                                          item.code?.toLowerCase() !=
                                              'umum') ...[
                                        const Gap(2),
                                        Text(
                                          item.alias!,
                                          style: theme.typography.body.sm.copyWith(
                                            color: theme.colors.mutedForeground,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    FLucideIcons.check,
                                    size: 18,
                                    color: theme.colors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Urutan yang diminta di sheet: Kata Kerja, Kata Sifat, Kata Benda.
const _shortcutCodes = ['v', 'adj', 'n'];

const _shortcutAliases = {
  'v': 'kata kerja',
  'adj': 'kata sifat',
  'n': 'kata benda',
};

List<WordClassPickItem> _shortcuts(List<WordClassPickItem> items) {
  final picked = <WordClassPickItem>[];
  for (final code in _shortcutCodes) {
    for (final item in items) {
      final itemCode = item.code?.trim().toLowerCase() ?? '';
      final alias = item.alias?.trim().toLowerCase() ?? '';
      final name = item.name.trim().toLowerCase();
      final label = _shortcutAliases[code];
      if (itemCode == code || alias == label || name == label) {
        picked.add(item);
        break;
      }
    }
  }
  return picked;
}

String _shortcutLabel(WordClassPickItem item) {
  final alias = item.alias?.trim() ?? '';
  if (alias.isNotEmpty) return alias;
  return item.name;
}
