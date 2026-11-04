import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/encyclopedia.entity.dart';
import '../../encyclopedia_router.dart';
import '../providers/encyclopedia_list_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';

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
  bool _autoloadBusy = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  EncyclopediaListQuery get _queryKey =>
      EncyclopediaListQuery(categoryId: _categoryId, q: _query.trim());

  void _onScroll() {
    if (_autoloadBusy || !_scroll.hasClients) return;
    final state = ref.read(encyclopediaListProvider(_queryKey)).value;
    if (state == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.nextCursor == null) {
      return;
    }
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 300) {
      _autoloadBusy = true;
      ref
          .read(encyclopediaListProvider(_queryKey).notifier)
          .loadMore()
          .whenComplete(() => _autoloadBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final categories = ref.watch(encyclopediaCategoriesProvider);
    final listAsync = ref.watch(encyclopediaListProvider(_queryKey));

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.encyclopediaTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => encyclopediaPopOrGoExplore(context),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.penLine),
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
      childPad: true,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.encyclopediaSubtitle,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                _SearchField(
                  hint: l10n.encyclopediaSearchPlaceholder,
                  onChanged: (v) {
                    if (v.trim() != _query) setState(() => _query = v);
                  },
                ),
                const Gap(12),
                _CategoryChips(
                  categories: categories.value ?? [],
                  selected: _categoryId,
                  allLabel: l10n.encyclopediaFilterAll,
                  onSelect: (id) => setState(() => _categoryId = id),
                ),
                const Gap(16),
                listAsync.when(
                  loading: () => const _SkeletonList(),
                  error: (e, _) => _ErrorBody(
                    msg: l10n.encyclopediaLoadFailed,
                    retryLabel: l10n.encyclopediaRetry,
                    onRetry: () => ref
                        .read(encyclopediaListProvider(_queryKey).notifier)
                        .reload(),
                  ),
                  data: (state) {
                    if (state.items.isEmpty) {
                      return _EmptyBody(
                        title: l10n.encyclopediaEmptyTitle,
                        body: l10n.encyclopediaEmptyBody,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final item in state.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ArticleCard(item: item),
                          ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: FCircularProgress()),
                          ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
        prefixIcon: Icon(
          FLucideIcons.search,
          size: 18,
          color: theme.colors.mutedForeground,
        ),
        suffixIcon: _ctrl.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  FLucideIcons.x,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
                onPressed: () {
                  _ctrl.clear();
                  FocusScope.of(context).unfocus();
                  widget.onChanged('');
                },
              ),
        filled: true,
        fillColor: theme.colors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.allLabel,
    required this.onSelect,
  });
  final List<EncyclopediaCategory> categories;
  final String? selected;
  final String allLabel;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: allLabel,
            active: selected == null,
            onTap: () => onSelect(null),
            theme: theme,
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: c.name,
                active: selected == c.id,
                onTap: () => onSelect(c.id),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.theme,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colors.primary : theme.colors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.typography.body.sm.copyWith(
            color: active
                ? theme.colors.primaryForeground
                : theme.colors.foreground,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.item});
  final EncyclopediaArticleListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () => context.push(EncyclopediaRouter.detailPath(item.slug)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            if (item.coverUrl != null)
              SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImageWithFallback(
                  imageUrl: item.coverUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      item.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Icon(
                          FLucideIcons.tag,
                          size: 12,
                          color: theme.colors.mutedForeground,
                        ),
                        const Gap(4),
                        Text(
                          item.category.name,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            FLucideIcons.bookOpen,
            size: 48,
            color: theme.colors.mutedForeground,
          ),
          const Gap(12),
          Text(
            title,
            style: theme.typography.body.lg.copyWith(
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
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 40,
            color: theme.colors.destructive,
          ),
          const Gap(12),
          Text(
            msg,
            style: theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          FButton(onPress: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        children: List.generate(
          6,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 100, height: 100),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 160, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
