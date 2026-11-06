import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';
import '../../domain/encyclopedia.entity.dart';
import '../../encyclopedia_router.dart';
import '../providers/encyclopedia_list_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';

/// Grid 3 kolom - seragam dengan wisata / usaha: foto 1:1 + judul maks 2 baris.
const _encyclopediaGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 12,
  crossAxisSpacing: 8,
  childAspectRatio: 0.7,
);

class EncyclopediaArticleListPage extends ConsumerStatefulWidget {
  const EncyclopediaArticleListPage({super.key, this.initialCategoryId});
  final String? initialCategoryId;

  @override
  ConsumerState<EncyclopediaArticleListPage> createState() =>
      _EncyclopediaArticleListPageState();
}

class _EncyclopediaArticleListPageState
    extends ConsumerState<EncyclopediaArticleListPage> {
  String? _categoryId;
  String _query = '';
  final _scroll = ScrollController();
  Timer? _debounce;
  bool _autoloadBusy = false;
  Object? _fillToken;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  EncyclopediaListQuery get _queryKey =>
      EncyclopediaListQuery(categoryId: _categoryId, q: _query.trim());

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value);
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _onScroll() {
    if (_autoloadBusy || !_scroll.hasClients) return;
    final state = ref.read(encyclopediaListProvider(_queryKey)).value;
    if (state == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.nextCursor == null) {
      return;
    }
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 200) {
      _autoloadBusy = true;
      ref
          .read(encyclopediaListProvider(_queryKey).notifier)
          .loadMore()
          .whenComplete(() => _autoloadBusy = false);
    }
  }

  void _scheduleFillCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final state = ref.read(encyclopediaListProvider(_queryKey)).value;
      if (state == null || !state.hasMore || state.isLoadingMore) return;
      if (_scroll.position.maxScrollExtent <= _scroll.position.pixels) {
        _onScroll();
      }
    });
  }

  Future<void> _reload() async {
    await ref.read(encyclopediaListProvider(_queryKey).notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queryKey = _queryKey;
    final listAsync = ref.watch(encyclopediaListProvider(queryKey));
    final categories = ref.watch(encyclopediaCategoriesProvider).value ?? [];

    return ExcludeSemanticsOnExit(
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(l10n.encyclopediaTitle),
          prefixes: [
            FHeaderAction.back(
              onPress: () => encyclopediaPopOrGoExplore(context),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              onPress: () async {
                final ok = await ensureEncyclopediaAuth(
                  context,
                  ref,
                  body: l10n.encyclopediaLoginMyContributionsBody,
                );
                if (!ok || !context.mounted) return;
                context.push(EncyclopediaRouter.myContributions.path);
              },
            ),
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: () async {
                final ok = await ensureEncyclopediaAuth(
                  context,
                  ref,
                  body: l10n.encyclopediaLoginContributeBody,
                );
                if (!ok || !context.mounted) return;
                context.push(EncyclopediaRouter.contribute.path);
              },
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
              hint: l10n.encyclopediaSearchPlaceholder,
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
                allLabel: l10n.encyclopediaFilterAll,
                onSelect: (id) {
                  setState(() => _categoryId = id);
                  if (_scroll.hasClients) _scroll.jumpTo(0);
                },
              ),
              const Gap(12),
            ],
            Expanded(
              child: listAsync.when(
                loading: () => const _SkeletonGrid(),
                error: (_, _) => _ErrorBody(
                  msg: l10n.encyclopediaLoadFailed,
                  retryLabel: l10n.encyclopediaRetry,
                  onRetry: _reload,
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return _EmptyBody(
                      title: l10n.encyclopediaEmptyTitle,
                      body: l10n.encyclopediaEmptyBody,
                      onRefresh: _reload,
                    );
                  }
                  final fillToken = Object.hash(
                    queryKey,
                    state.items.length,
                    state.hasMore,
                  );
                  if (state.hasMore && fillToken != _fillToken) {
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
                          gridDelegate: _encyclopediaGridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (context, i) =>
                                _ArticleGridTile(item: state.items[i]),
                            childCount: state.items.length,
                          ),
                        ),
                        if (state.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: FCircularProgress(size: .sm),
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

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.allLabel,
    required this.onSelect,
  });

  final List<EncyclopediaCategory> categories;
  final String? selectedId;
  final String allLabel;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
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
              child: Text(allLabel),
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

class _ArticleGridTile extends StatelessWidget {
  const _ArticleGridTile({required this.item});

  final EncyclopediaArticleListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = item.coverUrl;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final titleHeight = (titleStyle.fontSize ?? 12) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(EncyclopediaRouter.detailPath(item.slug)),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover == null || cover.isEmpty
                    ? ColoredBox(
                        color: theme.colors.muted,
                        child: Icon(
                          FLucideIcons.bookOpen,
                          size: 28,
                          color: theme.colors.mutedForeground,
                        ),
                      )
                    : CachedNetworkImageWithFallback(
                        imageUrl: displayImageUrl(cover, width: 360) ?? cover,
                        fallbackUrl: cover,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const Gap(6),
            SizedBox(
              height: titleHeight,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ],
        ),
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
        gridDelegate: _encyclopediaGridDelegate,
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
  const _EmptyBody({
    required this.title,
    required this.body,
    required this.onRefresh,
  });

  final String title;
  final String body;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Gap(48),
          Center(
            child: Icon(
              FLucideIcons.bookOpen,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.msg,
    required this.retryLabel,
    required this.onRetry,
  });

  final String msg;
  final String retryLabel;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FAlert(title: Text(msg)),
          const Gap(16),
          FButton(onPress: () => onRetry(), child: Text(retryLabel)),
        ],
      ),
    );
  }
}
