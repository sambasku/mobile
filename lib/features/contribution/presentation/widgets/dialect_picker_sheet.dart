import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

class DialectPickItem {
  const DialectPickItem({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;
}

/// Bottom sheet pilih dialek - tinggi form tetap (bukan ExpansionTile).
Future<DialectPickItem?> showDialectPickerSheet(
  BuildContext context, {
  required List<DialectPickItem> items,
  String? selectedId,
}) {
  return showModalBottomSheet<DialectPickItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _DialectPickerSheetBody(items: items, selectedId: selectedId);
    },
  );
}

class _DialectPickerSheetBody extends StatelessWidget {
  const _DialectPickerSheetBody({
    required this.items,
    required this.selectedId,
  });

  final List<DialectPickItem> items;
  final String? selectedId;

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    // Dialek biasanya sedikit - sheet lebih pendek dari kelas kata.
    final target = available * 0.45;
    return target.clamp(220.0, available);
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
                Icon(
                  FLucideIcons.mapPin,
                  size: 18,
                  color: theme.colors.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Pilih dialek',
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
              'Default otomatis · bisa diganti',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada dialek',
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
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.typography.body.sm.copyWith(
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: selected
                                                ? theme.colors.primary
                                                : theme.colors.foreground,
                                          ),
                                        ),
                                      ),
                                      if (item.isDefault) ...[
                                        const Gap(8),
                                        Text(
                                          'default',
                                          style: theme.typography.body.sm.copyWith(
                                            color: theme.colors.mutedForeground,
                                            fontSize: 11,
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
