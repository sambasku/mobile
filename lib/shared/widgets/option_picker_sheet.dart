import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Satu opsi untuk [showOptionPickerSheet]. `selected` diisi pemanggil
/// (bukan dibandingkan lewat `==`) supaya nilai null pun bisa jadi opsi.
class OptionPickerItem<T> {
  const OptionPickerItem({
    required this.value,
    required this.label,
    this.detail,
    this.selected = false,
  });

  final T value;
  final String label;

  /// Penjelasan singkat di bawah label. Boleh panjang - baris menggulir.
  final String? detail;
  final bool selected;
}

/// Bottom sheet pilihan tunggal - satu tampilan untuk semua picker
/// (kategori wisata/acara, platform sumber, kecamatan, desa).
///
/// Gaya sama dengan pemilih jenis entri: ikon + judul, keterangan kecil,
/// divider, lalu daftar baris dengan tanda centang di kanan. Tinggi
/// di-clamp ke viewport supaya daftar panjang tetap menggulir.
Future<T?> showOptionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<OptionPickerItem<T>> items,
  IconData icon = FLucideIcons.listFilter,
  String? subtitle,
  bool searchable = false,
  String searchHint = 'Cari',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (sheetContext) => _OptionPickerSheetBody<T>(
      title: title,
      items: items,
      icon: icon,
      subtitle: subtitle,
      searchable: searchable,
      searchHint: searchHint,
    ),
  );
}

class _OptionPickerSheetBody<T> extends StatefulWidget {
  const _OptionPickerSheetBody({
    required this.title,
    required this.items,
    required this.icon,
    required this.subtitle,
    required this.searchable,
    required this.searchHint,
  });

  final String title;
  final List<OptionPickerItem<T>> items;
  final IconData icon;
  final String? subtitle;
  final bool searchable;
  final String searchHint;

  @override
  State<_OptionPickerSheetBody<T>> createState() =>
      _OptionPickerSheetBodyState<T>();
}

class _OptionPickerSheetBodyState<T> extends State<_OptionPickerSheetBody<T>> {
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
    // Daftar pendek (kategori/platform) tidak perlu separuh layar; daftar
    // panjang yang bisa dicari (kecamatan/desa) dapat porsi lebih besar.
    final target = available * (widget.searchable ? 0.72 : 0.5);
    return target.clamp(240.0, available);
  }

  List<OptionPickerItem<T>> get _visible {
    final q = _filter.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return [
      for (final item in widget.items)
        if (item.label.toLowerCase().contains(q)) item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final visible = _visible;
    final subtitle =
        widget.subtitle ??
        (widget.items.isEmpty
            ? 'Belum ada pilihan'
            : '${widget.items.length} pilihan - ketuk untuk memilih');

    // Offset keyboard: tanpa ini sheet menempel bawah layar dan keyboard
    // menutupi daftar hasil pencarian (viewInsets diukur dari root, bukan
    // dari dalam sheet).
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
                  Icon(widget.icon, size: 18, color: theme.colors.primary),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      widget.title,
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
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
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
                  hint: widget.searchHint,
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
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: visible.length,
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                      itemBuilder: (context, index) {
                        final item = visible[index];
                        final detail = item.detail?.trim();
                        return Semantics(
                          button: true,
                          selected: item.selected,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pop(item.value),
                              borderRadius: BorderRadius.circular(8),
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
                                            item.label,
                                            style: theme.typography.body.sm
                                                .copyWith(
                                                  fontWeight: item.selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: item.selected
                                                      ? theme.colors.primary
                                                      : theme.colors.foreground,
                                                ),
                                          ),
                                          if (detail != null &&
                                              detail.isNotEmpty) ...[
                                            const Gap(2),
                                            Text(
                                              detail,
                                              style: theme.typography.body.sm
                                                  .copyWith(
                                                    color: theme
                                                        .colors
                                                        .mutedForeground,
                                                    fontSize: 12,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (item.selected) ...[
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
          ],
        ),
      ),
    );
  }
}
