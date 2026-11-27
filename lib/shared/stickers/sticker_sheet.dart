import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../l10n/app_localizations.dart';
import '../utils/error_bottom_sheet.dart';
import 'create_custom_sticker_sheet.dart';
import 'sticker_models.dart';
import 'sticker_providers.dart';
import 'sticker_view.dart';

const _kStickerSheetLoginSentinel = '__sambasku_sticker_login__';

Future<String?> showCatalogStickerSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _StickerSheetBody(title: l10n.chatStickerSheetTitle),
  );
  if (result == _kStickerSheetLoginSentinel) {
    if (context.mounted) context.push('/login');
    return null;
  }
  return result;
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
  var _handledExit = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(stickerPickerProvider.notifier).reload();
      final auth = ref.read(authStatusProvider).value;
      if (auth?.isAuth == true) {
        ref.read(stickerFavoritesProvider.notifier).load(force: false);
        ref.read(myStickersProvider.notifier).load(force: false);
      }
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

  void _exitWith(String? value) {
    if (_handledExit) return;
    _handledExit = true;
    Navigator.of(context).pop(value);
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
      if (!mounted) return;
      ref.read(stickerPickerProvider.notifier).setQuery(value);
    });
  }

  List<CatalogSticker> _filterLocal(List<CatalogSticker> items, String q) {
    final needle = q.trim().toLowerCase();
    if (needle.isEmpty) return items;
    return items
        .where(
          (s) =>
              s.id.toLowerCase().contains(needle) ||
              (s.displayName?.toLowerCase().contains(needle) ?? false),
        )
        .toList(growable: false);
  }

  Future<void> _onLongPressFavorite(CatalogSticker sticker) async {
    final l10n = AppLocalizations.of(context);
    final remove = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTileGroup(
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.starOff, size: 18),
                      title: Text(l10n.stickerRemoveFromFavorites),
                      onPress: () => Navigator.of(sheetContext).pop(true),
                    ),
                    FTile(
                      title: Text(l10n.commonCancel),
                      onPress: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (remove != true || !mounted) return;
    final res = await ref.read(stickerFavoritesProvider.notifier).toggle(sticker);
    if (!mounted) return;
    if (res.ok) {
      showFToast(
        context: context,
        title: Text(l10n.stickerRemovedFromFavorites),
      );
    } else if (res.errorCode == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(l10n.commonRateLimited));
    } else {
      await showAppErrorSheet(
        context,
        message: l10n.stickerFavoriteActionFailed,
      );
    }
  }

  Future<void> _onLongPressMine(CatalogSticker sticker) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTileGroup(
                  children: [
                    FTile(
                      title: Text(l10n.stickerDeleteMineTitle),
                      subtitle: Text(l10n.stickerDeleteMineBody),
                    ),
                    FTile(
                      prefix: const Icon(FLucideIcons.trash2, size: 18),
                      title: Text(l10n.stickerDeleteMineConfirm),
                      onPress: () => Navigator.of(sheetContext).pop(true),
                    ),
                    FTile(
                      title: Text(l10n.commonCancel),
                      onPress: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final errCode =
        await ref.read(myStickersProvider.notifier).deleteMine(sticker.id);
    if (!mounted) return;
    if (errCode == null) {
      showFToast(context: context, title: Text(l10n.stickerDeleteMineSuccess));
    } else if (errCode == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(l10n.commonRateLimited));
    } else {
      await showAppErrorSheet(context, message: l10n.stickerDeleteMineFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    final state = ref.watch(stickerPickerProvider);
    final favState = ref.watch(stickerFavoritesProvider);
    final mineState = ref.watch(myStickersProvider);
    final isAuth = ref.watch(authStatusProvider).value?.isAuth ?? false;

    final Widget gridContent = switch (state.tab) {
      StickerDeckTab.favorites => !isAuth
          ? _GuestTabPrompt(
              message: l10n.stickerFavoritesLoginHint,
              ctaLabel: l10n.stickerLoginAction,
              onLogin: () => _exitWith(_kStickerSheetLoginSentinel),
            )
          : _buildStickerGrid(
              theme: theme,
              items: _filterLocal(favState.items, state.q),
              loading: favState.loading && favState.items.isEmpty,
              loadingMore: false,
              emptyText: state.q.trim().isNotEmpty
                  ? l10n.stickerSearchEmpty
                  : l10n.stickerFavoritesEmpty,
              onLongPressItem: _onLongPressFavorite,
            ),
      StickerDeckTab.mine => !isAuth
          ? _GuestTabPrompt(
              message: l10n.stickerMineLoginHint,
              ctaLabel: l10n.stickerLoginAction,
              onLogin: () => _exitWith(_kStickerSheetLoginSentinel),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FButton(
                      variant: FButtonVariant.outline,
                      prefix: const Icon(FLucideIcons.plus, size: 16),
                      onPress: () => showCreateCustomStickerSheet(context),
                      child: Text(l10n.stickerCreateButton),
                    ),
                  ),
                ),
                Flexible(
                  child: _buildStickerGrid(
                    theme: theme,
                    items: _filterLocal(mineState.items, state.q),
                    loading: mineState.loading && mineState.items.isEmpty,
                    loadingMore: false,
                    emptyText: state.q.trim().isNotEmpty
                        ? l10n.stickerSearchEmpty
                        : l10n.stickerMineEmpty,
                    onLongPressItem: _onLongPressMine,
                  ),
                ),
              ],
            ),
      StickerDeckTab.catalog => _buildStickerGrid(
          theme: theme,
          items: state.items,
          loading: state.loading && state.items.isEmpty,
          loadingMore: state.loadingMore,
          emptyText: l10n.stickerSearchEmpty,
        ),
    };

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.stickerTabFavorites,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(stickerPickerProvider.notifier)
                              .setTab(StickerDeckTab.favorites);
                          if (isAuth) {
                            ref
                                .read(stickerFavoritesProvider.notifier)
                                .load(force: false);
                          }
                        },
                        child: FBadge(
                          variant: state.tab == StickerDeckTab.favorites
                              ? FBadgeVariant.primary
                              : FBadgeVariant.secondary,
                          child: const Icon(FLucideIcons.star, size: 14),
                        ),
                      ),
                    ),
                    const Gap(6),
                    Semantics(
                      button: true,
                      label: l10n.stickerTabMine,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(stickerPickerProvider.notifier)
                              .setTab(StickerDeckTab.mine);
                          if (isAuth) {
                            ref
                                .read(myStickersProvider.notifier)
                                .load(force: false);
                          }
                        },
                        child: FBadge(
                          variant: state.tab == StickerDeckTab.mine
                              ? FBadgeVariant.primary
                              : FBadgeVariant.secondary,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FLucideIcons.smilePlus, size: 14),
                              const Gap(4),
                              Text(l10n.stickerTabMine),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(6),
                    GestureDetector(
                      onTap: () => ref
                          .read(stickerPickerProvider.notifier)
                          .setCategory(null),
                      child: FBadge(
                        variant: state.tab == StickerDeckTab.catalog &&
                                state.categorySlug == null
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(l10n.stickerTabAll),
                      ),
                    ),
                    for (final cat in state.categories) ...[
                      const Gap(6),
                      GestureDetector(
                        onTap: () => ref
                            .read(stickerPickerProvider.notifier)
                            .setCategory(cat),
                        child: FBadge(
                          variant: state.tab == StickerDeckTab.catalog &&
                                  state.categorySlug == cat
                              ? FBadgeVariant.primary
                              : FBadgeVariant.secondary,
                          child: Text(cat),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: gridContent,
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid({
    required FThemeData theme,
    required List<CatalogSticker> items,
    required bool loading,
    required bool loadingMore,
    required String emptyText,
    void Function(CatalogSticker sticker)? onLongPressItem,
  }) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: FCircularProgress(size: .md)),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }
    return GridView.builder(
      controller: _scroll,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: items.length + (loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Center(
            child: FCircularProgress(size: .sm),
          );
        }
        final sticker = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _exitWith(sticker.id),
          onLongPress:
              onLongPressItem == null ? null : () => onLongPressItem(sticker),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.secondary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Semantics(
                  label: sticker.label,
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
    );
  }
}

class _GuestTabPrompt extends StatelessWidget {
  const _GuestTabPrompt({
    required this.message,
    required this.ctaLabel,
    required this.onLogin,
  });

  final String message;
  final String ctaLabel;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          FButton(
            onPress: onLogin,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}
