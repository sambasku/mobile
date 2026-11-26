import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dictionary/domain/entities/word_detail.dart';

/// Satu opsi kategori topik lemma (master `categories`).
class CategoryPickItem {
  const CategoryPickItem({required this.id, required this.name});

  final String id;
  final String name;
}

/// Bottom sheet multi-select kategori lemma. Pop dengan [Set] id terpilih;
/// `null` = batal (tutup tanpa Simpan).
Future<Set<String>?> showCategoryMultiPickerSheet(
  BuildContext context, {
  required List<CategoryPickItem> items,
  required Set<String> selectedIds,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (sheetContext) => _CategoryMultiPickerBody(
      items: items,
      initialSelected: selectedIds,
    ),
  );
}

class _CategoryMultiPickerBody extends StatefulWidget {
  const _CategoryMultiPickerBody({
    required this.items,
    required this.initialSelected,
  });

  final List<CategoryPickItem> items;
  final Set<String> initialSelected;

  @override
  State<_CategoryMultiPickerBody> createState() =>
      _CategoryMultiPickerBodyState();
}

class _CategoryMultiPickerBodyState extends State<_CategoryMultiPickerBody> {
  late final Set<String> _selected;
  final _query = TextEditingController();
  var _filter = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    return (available * 0.72).clamp(280.0, available);
  }

  List<CategoryPickItem> get _visible {
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
    final l10n = AppLocalizations.of(context);
    final visible = _visible;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: _sheetHeight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.tags,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      l10n.contributeCategorySheetTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
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
                l10n.contributeCategorySheetSubtitle,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: FTextField(
                control: FTextFieldControl.managed(
                  controller: _query,
                  onChange: (v) => setState(() => _filter = v.text),
                ),
                hint: l10n.contributeCategorySearchHint,
                clearable: (value) => value.text.isNotEmpty,
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
                        l10n.contributeCategoryEmpty,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final item = visible[index];
                        final on = _selected.contains(item.id);
                        return Semantics(
                          button: true,
                          selected: on,
                          // InkWell butuh Material transparan (pola sama dengan
                          // option_picker_sheet / dialect_picker_sheet).
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() {
                                if (on) {
                                  _selected.remove(item.id);
                                } else {
                                  _selected.add(item.id);
                                }
                              }),
                              borderRadius: BorderRadius.circular(8),
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
                                        style: theme.typography.body.sm
                                            .copyWith(
                                              fontWeight: on
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: on
                                                  ? theme.colors.primary
                                                  : theme.colors.foreground,
                                            ),
                                      ),
                                    ),
                                    if (on) ...[
                                      const Gap(8),
                                      Icon(
                                        FLucideIcons.check,
                                        size: 18,
                                        color: theme.colors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: () =>
                      Navigator.of(context).pop(Set<String>.from(_selected)),
                  child: Text(l10n.contributeCategorySheetDone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map [WordCategory] → item picker.
List<CategoryPickItem> categoryPickItemsFrom(List<WordCategory> categories) => [
  for (final c in categories) CategoryPickItem(id: c.id, name: c.name),
];
