import 'dart:async';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'sticker_providers.dart';
import 'sticker_view.dart';

Future<String?> showCatalogStickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => _StickerSheetBody(title: l10n.chatStickerSheetTitle),
  );
}

class _StickerSheetBody extends ConsumerStatefulWidget {
  const _StickerSheetBody({required this.title});

  final String title;

  @override
  ConsumerState<_StickerSheetBody> createState() => _StickerSheetBodyState();
}

class _StickerSheetBodyState extends ConsumerState<_StickerSheetBody> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stickerPickerProvider.notifier).reload();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      ref.read(stickerPickerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(stickerPickerProvider.notifier).setQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    final state = ref.watch(stickerPickerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: _searchCtrl,
                onChange: (value) => _onSearchChanged(value.text),
              ),
              hint: l10n.stickerSearchHint,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(stickerPickerProvider.notifier)
                        .setCategory(null),
                    child: FBadge(
                      variant: state.categorySlug == null
                          ? FBadgeVariant.primary
                          : FBadgeVariant.secondary,
                      child: Text(l10n.stickerTabAll),
                    ),
                  ),
                  for (final cat in state.categories)
                    GestureDetector(
                      onTap: () => ref
                          .read(stickerPickerProvider.notifier)
                          .setCategory(cat),
                      child: FBadge(
                        variant: state.categorySlug == cat
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(cat),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: state.loading && state.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: FCircularProgress(size: .md)),
                  )
                : state.items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.stickerSearchEmpty,
                          style: theme.typography.body.sm,
                        ),
                      )
                    : GridView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount:
                            state.items.length + (state.loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Center(
                              child: FCircularProgress(size: .sm),
                            );
                          }
                          final sticker = state.items[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(context, sticker.id),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colors.secondary
                                    .withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Center(
                                  child: Semantics(
                                    label: sticker.id,
                                    child: CatalogStickerView(
                                      sticker: sticker,
                                      size: 64,
                                    ),
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
    );
  }
}

