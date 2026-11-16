import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../explore/explore_router.dart';
import '../../karya_router.dart';
import '../../domain/karya.dart';
import '../karya_providers.dart';

class KaryaListPage extends ConsumerStatefulWidget {
  const KaryaListPage({super.key});

  @override
  ConsumerState<KaryaListPage> createState() => _KaryaListPageState();
}

class _KaryaListPageState extends ConsumerState<KaryaListPage> {
  String? _kind;
  String _q = '';
  Timer? _debounce;

  KaryaBrowseQuery get _query => KaryaBrowseQuery(kind: _kind, q: _q);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _q = value);
    });
  }

  Future<void> _propose() async {
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    context.push(KaryaRouter.contribute.path);
  }

  Future<void> _reload() async {
    ref.invalidate(karyaBrowseProvider(_query));
    await ref.read(karyaBrowseProvider(_query).future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(karyaBrowseProvider(_query));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.karyaTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(ExploreRouter.hub.path),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.clipboardList),
            onPress: () async {
              final authed =
                  ref.read(authStatusProvider).value?.isAuth ?? false;
              if (!authed) {
                context.push('/login');
                return;
              }
              context.push(KaryaRouter.proposals.path);
            },
          ),
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: _propose,
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
            hint: l10n.karyaSearchPlaceholder,
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
          const Gap(8),
          _KindBar(
            selected: _kind,
            onSelect: (value) => setState(() => _kind = value),
          ),
          const Gap(8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => Center(child: Text(l10n.karyaLoadFailed)),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyBody(
                    hasFilter: _kind != null || _q.trim().isNotEmpty,
                    onPropose: _propose,
                    onRefresh: _reload,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _KaryaListTile(
                      item: items[i],
                      showKind: _kind == null,
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

class _KaryaListTile extends StatelessWidget {
  const _KaryaListTile({
    required this.item,
    required this.showKind,
  });

  final KaryaEntry item;
  final bool showKind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kindLabel =
        item.isMusic ? l10n.karyaKindMusic : l10n.karyaKindFilm;
    final subtitle = showKind
        ? '$kindLabel · ${l10n.karyaYearLabel(item.year)}'
        : l10n.karyaYearLabel(item.year);

    return FTappable(
      onPress: () => context.push(KaryaRouter.detailPath(item.slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              item.isMusic ? FLucideIcons.music : FLucideIcons.clapperboard,
              size: 28,
              color: theme.colors.primary,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Icon(
              FLucideIcons.chevronRight,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _KindBar extends StatelessWidget {
  const _KindBar({
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: l10n.usahaFilterAll,
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          const Gap(6),
          _chip(
            label: l10n.karyaKindMusic,
            active: selected == 'music',
            onTap: () => onSelect('music'),
          ),
          const Gap(6),
          _chip(
            label: l10n.karyaKindFilm,
            active: selected == 'film',
            onTap: () => onSelect('film'),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FBadge(
        variant: active ? FBadgeVariant.primary : FBadgeVariant.secondary,
        child: Text(label),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.hasFilter,
    required this.onPropose,
    required this.onRefresh,
  });

  final bool hasFilter;
  final VoidCallback onPropose;
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
              FLucideIcons.clapperboard,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          Text(
            hasFilter ? l10n.karyaEmptyFilter : l10n.karyaEmpty,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            hasFilter ? l10n.karyaEmptyFilterHint : l10n.karyaEmptyHint,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          Center(
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: onPropose,
              child: Text(l10n.karyaContribute),
            ),
          ),
        ],
      ),
    );
  }
}