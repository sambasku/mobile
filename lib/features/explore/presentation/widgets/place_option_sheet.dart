import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../data/place_contribution_api.dart';

/// Bottom sheet pilihan tunggal. Pola sama dengan pemilih kelas kata.
Future<PlaceOption?> showPlaceOptionSheet(
  BuildContext context, {
  required String title,
  required List<PlaceOption> items,
  String? selectedId,
  IconData icon = FLucideIcons.tags,
  bool searchable = false,
}) {
  return showModalBottomSheet<PlaceOption>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _PlaceOptionSheetBody(
        title: title,
        items: items,
        selectedId: selectedId,
        icon: icon,
        searchable: searchable,
      );
    },
  );
}

class _PlaceOptionSheetBody extends StatefulWidget {
  const _PlaceOptionSheetBody({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.icon,
    required this.searchable,
  });

  final String title;
  final List<PlaceOption> items;
  final String? selectedId;
  final IconData icon;
  final bool searchable;

  @override
  State<_PlaceOptionSheetBody> createState() => _PlaceOptionSheetBodyState();
}

class _PlaceOptionSheetBodyState extends State<_PlaceOptionSheetBody> {
  final _query = TextEditingController();
  var _filter = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * (widget.searchable ? 0.72 : 0.45);
    return target.clamp(240.0, available);
  }

  List<PlaceOption> get _visible {
    final q = _filter.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return [
      for (final item in widget.items)
        if (item.name.toLowerCase().contains(q)) item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final visible = _visible;
    return SizedBox(
      height: _sheetHeight(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: theme.colors.primary),
                const Gap(8),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(FLucideIcons.x),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              widget.items.isEmpty
                  ? 'Belum ada pilihan'
                  : '${widget.items.length} pilihan - ketuk untuk memilih',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: FTextField(
                control: FTextFieldControl.managed(
                  controller: _query,
                  onChange: (value) => setState(() => _filter = value.text),
                ),
                hint: 'Cari nama',
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      widget.items.isEmpty
                          ? 'Tidak ada data'
                          : 'Tidak ada yang cocok',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                    itemBuilder: (context, index) {
                      final item = visible[index];
                      final selected = item.id == widget.selectedId;
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
                                  child: Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.sm.copyWith(
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? theme.colors.primary
                                          : theme.colors.foreground,
                                    ),
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
