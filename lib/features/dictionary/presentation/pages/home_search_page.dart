import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../activity/domain/entities/feed_activity_item.dart';
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../discussion/presentation/widgets/discussion_home_banner.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../dictionary_router.dart';
import '../providers/word_of_day_providers.dart';
import '../widgets/word_of_day_card.dart';

/// Tab HOME: feed lintas aktivitas publik + Kata Hari Ini.
class HomeSearchPage extends HookConsumerWidget {
  const HomeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityFeedProvider);
    final scroll = useScrollController();

    final lastDayId = useRef<String?>(null);
    final wotdResolvedOnce = useRef(false);
    final wotdAsync = ref.watch(wordOfDayProvider);
    final wotdData = wotdAsync.asData;
    if (wotdData != null || wotdAsync.hasError) {
      wotdResolvedOnce.value = true;
      if (wotdData != null) {
        lastDayId.value = wotdData.value?.word.id;
      }
    }
    final dayId = lastDayId.value;
    final feedReady = wotdResolvedOnce.value;

    useOnAppLifecycleStateChange((previous, current) {
      if (current != AppLifecycleState.resumed) return;
      if (previous == null || previous == AppLifecycleState.resumed) return;
      ref.invalidate(wordOfDayProvider);
      ref.read(activityFeedProvider.notifier).load();
    });

    return Column(
      children: [
        const FHeader(
          title: Text('SambasKu'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          child: GestureDetector(
            onTap: () => context.push('${DictionaryRouter.list.path}?focus=1'),
            child: AbsorbPointer(
              child: FTextField(
                size: .sm,
                readOnly: true,
                hint: 'Cari kata Sambas...',
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildBody(
            context,
            ref,
            state,
            scroll,
            dayId: dayId,
            feedReady: feedReady,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ActivityFeedState state,
    ScrollController scroll, {
    required String? dayId,
    required bool feedReady,
  }) {
    if (state.isLoading && state.items.isEmpty) {
      return const _FeedSkeleton();
    }

    final items = feedReady
        ? [
            for (final item in state.items)
              if (!_isWordOfDayDuplicate(item, dayId)) item,
          ]
        : const <FeedActivityItem>[];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
        children: [
          const WordOfDayCard(),
          const DiscussionHomeBanner(),
          const _FeedHeading(),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FAlert(
                variant: FAlertVariant.destructive,
                title: Text(state.errorMessage!),
              ),
            ),
          if (!feedReady)
            const _FeedListSkeleton()
          else if (items.isEmpty && state.errorMessage == null)
            const _EmptyFeed()
          else
            for (var i = 0; i < items.length; i++) ...[
              _ActivityFeedRow(item: items[i]),
              if (i != items.length - 1)
                Divider(height: 1, color: context.theme.colors.border),
            ],
        ],
      ),
    );
  }

  static bool _isWordOfDayDuplicate(FeedActivityItem item, String? dayId) {
    if (dayId == null || dayId.isEmpty) return false;
    if (item.kind != FeedActivityKind.word) return false;
    return item.target?.type == 'word' && item.target?.id == dayId;
  }

  Future<void> _refresh(WidgetRef ref) async {
    final store = ref.read(responseCacheStoreProvider);
    await store.delete(
      buildCacheKey(method: 'GET', path: '/api/v1/words/today'),
    );
    await store.deleteByPrefix('GET|/api/v1/activity');
    ref.invalidate(wordOfDayProvider);
    await Future.wait([
      ref.read(activityFeedProvider.notifier).load(forceRefresh: true),
      ref.read(wordOfDayProvider.future),
    ]);
  }
}

class _FeedHeading extends StatelessWidget {
  const _FeedHeading();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Text(
        'Aktivitas terbaru',
        style: theme.typography.sm.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colors.foreground,
        ),
      ),
    );
  }
}

class _ActivityFeedRow extends StatelessWidget {
  const _ActivityFeedRow({required this.item});

  final FeedActivityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final actorLabel = item.actor == null
        ? 'Seseorang'
        : displayPublicAccountLabel(
            displayName: item.actor!.displayName,
            username: item.actor!.username,
          );
    final canOpenProfile = isLinkablePublicUsername(item.actor?.username);
    final dateLabel = formatRelativeCompact(
      DateTime.tryParse(item.createdAt),
    );
    final trailingMeta = [
      if (dateLabel.isNotEmpty) dateLabel,
      if (item.subtitle != null && item.subtitle!.trim().isNotEmpty)
        item.subtitle!.trim(),
    ].join(' · ');

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: actorLabel,
          imageUrl: item.actor?.avatarUrl,
          size: 28,
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canOpenProfile
                          ? () => UserProfileRouter.open(
                                context,
                                item.actor!.username!,
                              )
                          : null,
                      child: Text(
                        actorLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: canOpenProfile
                              ? theme.colors.primary
                              : theme.colors.foreground,
                        ),
                      ),
                    ),
                  ),
                  if (trailingMeta.isNotEmpty) ...[
                    const Gap(6),
                    Text(
                      trailingMeta,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                item.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ],
    );

    final path = _navigatePath(item);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: path == null
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.push(path);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: content,
        ),
      ),
    );
  }

  String? _navigatePath(FeedActivityItem item) {
    final target = item.target;
    if (target == null) return null;
    switch (target.type) {
      case 'word':
        return DictionaryRouter.detail.path.replaceFirst(':id', target.id);
      case 'discussion':
        return DiscussionRouter.detailPath(target.id);
      case 'search_miss':
        final term = _searchMissTerm(item);
        final q = Uri(
          queryParameters: <String, String>{
            if (term != null && term.isNotEmpty) 'lemma': term,
            'miss_id': target.id,
          },
        ).query;
        return '${ContributionRouter.contribute.path}?$q';
      default:
        return null;
    }
  }

  String? _searchMissTerm(FeedActivityItem item) {
    // body: "mencari {term} tapi tidak terdapat. Bantu isi."
    final body = item.body;
    const prefix = 'mencari ';
    const suffix = ' tapi tidak terdapat';
    if (!body.startsWith(prefix) || !body.contains(suffix)) return null;
    return body.substring(prefix.length, body.indexOf(suffix)).trim();
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            FLucideIcons.bookOpen,
            size: 36,
            color: theme.colors.mutedForeground,
          ),
          const Gap(8),
          Text(
            'Belum ada aktivitas.',
            textAlign: TextAlign.center,
            style: theme.typography.md.copyWith(color: theme.colors.foreground),
          ),
        ],
      ),
    );
  }
}

class _FeedListSkeleton extends StatelessWidget {
  const _FeedListSkeleton();

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    final placeholder = FeedActivityItem(
      id: 'skeleton',
      kind: FeedActivityKind.comment,
      createdAt: DateTime.now().toIso8601String(),
      body: 'aktivitas singkat satu baris',
      actor: const FeedActivityActor(
        username: 'warga',
        displayName: 'Warga Sambas',
      ),
      subtitle: 'lading',
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                _ActivityFeedRow(item: placeholder),
                if (i != 3)
                  Divider(height: 1, color: context.theme.colors.border),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
      children: const [
        WordOfDayCard(),
        DiscussionHomeBanner(),
        _FeedHeading(),
        _FeedListSkeleton(),
      ],
    );
  }
}
