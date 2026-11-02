import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_browse_providers.dart';
import '../providers/usaha_providers.dart';
import '../widgets/usaha_ui.dart';

/// Grid 3 kolom - seragam dengan wisata, kuliner, dan acara: foto kotak 1:1
/// + nama maks 2 baris.
const _usahaGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 12,
  crossAxisSpacing: 8,
  childAspectRatio: 0.7,
);

/// Direktori usaha & jasa lokal Sambas.
class UsahaListPage extends ConsumerStatefulWidget {
  const UsahaListPage({super.key});

  @override
  ConsumerState<UsahaListPage> createState() => _UsahaListPageState();
}

class _UsahaListPageState extends ConsumerState<UsahaListPage> {
  String? _categoryId;
  String _query = '';
  final _scroll = ScrollController();
  Timer? _debounce;
  Object? _fillToken;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  UsahaBrowseQuery get _browseQuery =>
      UsahaBrowseQuery(categoryId: _categoryId, q: _query.trim());

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value);
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final data = ref.read(usahaBrowseProvider(_browseQuery)).value;
    if (data == null ||
        !data.hasMore ||
        data.isLoadingMore ||
        data.loadMoreFailed) {
      return;
    }
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 200) {
      ref.read(usahaBrowseProvider(_browseQuery).notifier).loadMore();
    }
  }

  /// Halaman penuh tapi viewport belum penuh (layar besar) - paksa muat
  /// lagi sampai bisa scroll atau habis.
  void _scheduleFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final data = ref.read(usahaBrowseProvider(_browseQuery)).value;
      if (data == null || !data.hasMore || data.isLoadingMore) return;
      if (_scroll.position.maxScrollExtent <= _scroll.position.pixels) {
        _maybeLoadMore();
      }
    });
  }

  Future<void> _reload() async {
    await ref.read(usahaBrowseProvider(_browseQuery).notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final browseQuery = _browseQuery;
    final browseAsync = ref.watch(usahaBrowseProvider(browseQuery));
    final categories = ref.watch(usahaCategoriesProvider).value ?? const [];

    return ExcludeSemanticsOnExit(
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(l10n.usahaTitle),
          prefixes: [
            FHeaderAction.back(
              onPress: () =>
                  context.canPop() ? context.pop() : context.go('/explore'),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              onPress: () => context.push(UsahaRouter.proposals.path),
            ),
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: () => context.push(UsahaRouter.contribute.path),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FTextField(
              control: FTextFieldControl.managed(
                onChange: (value) => _onSearchChanged(value.text),
              ),
              hint: l10n.usahaSearchHint,
              textInputAction: TextInputAction.search,
              clearable: (value) => value.text.isNotEmpty,
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const Icon(FLucideIcons.search),
                  ),
            ),
            const Gap(12),
            if (categories.isNotEmpty) ...[
              _CategoryBar(
                categories: categories,
                selectedId: _categoryId,
                onSelect: (id) {
                  setState(() => _categoryId = id);
                  if (_scroll.hasClients) _scroll.jumpTo(0);
                },
              ),
              const Gap(4),
            ],
            Expanded(
              child: browseAsync.when(
                loading: () => const _SkeletonGrid(),
                error: (_, _) => _ErrorBody(onRetry: _reload),
                data: (page) {
                  if (page.items.isEmpty) {
                    return _EmptyBody(
                      hasQuery: _query.trim().isNotEmpty,
                      onRefresh: _reload,
                    );
                  }
                  final fillToken = Object.hash(
                    browseQuery,
                    page.items.length,
                    page.hasMore,
                  );
                  if (page.hasMore && fillToken != _fillToken) {
                    _fillToken = fillToken;
                    _scheduleFillCheck();
                  }
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: CustomScrollView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverGrid(
                          gridDelegate: _usahaGridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => UsahaCard(usaha: page.items[i]),
                            childCount: page.items.length,
                          ),
                        ),
                        if (page.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: FCircularProgress(size: .sm),
                              ),
                            ),
                          ),
                        if (page.loadMoreFailed)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: FButton(
                                  variant: FButtonVariant.outline,
                                  onPress: () => ref
                                      .read(
                                        usahaBrowseProvider(
                                          browseQuery,
                                        ).notifier,
                                      )
                                      .loadMore(),
                                  child: Text(l10n.commonRetry),
                                ),
                              ),
                            ),
                          ),
                      ],
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

/// Chip kategori horizontal. "Semua" = tanpa filter.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<UsahaCategoryRef> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onSelect(null),
            child: FBadge(
              variant: selectedId == null
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(l10n.usahaFilterAll),
            ),
          ),
          for (final category in categories) ...[
            const Gap(6),
            GestureDetector(
              onTap: () => onSelect(category.id),
              child: FBadge(
                variant: selectedId == category.id
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(category.name),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: _usahaGridDelegate,
        itemCount: 8,
        itemBuilder: (_, _) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Bone(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Gap(6),
            Bone(width: double.infinity, height: 12),
            Gap(4),
            Bone(width: 72, height: 12),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.hasQuery, required this.onRefresh});

  final bool hasQuery;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Gap(48),
          Center(
            child: Icon(
              FLucideIcons.store,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          Text(
            hasQuery ? l10n.usahaListEmptyQuery : l10n.usahaListEmptyRegistered,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            hasQuery ? l10n.usahaListEmptyQueryHint : l10n.usahaListEmptyHint,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          Center(
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push(UsahaRouter.contribute.path),
              child: Text(l10n.usahaContributeAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FAlert(
            title: Text(l10n.usahaLoadFailed),
            subtitle: Text(l10n.usahaLoadFailedBody),
          ),
          const Gap(16),
          FButton(onPress: () => onRetry(), child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
