import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../entertainment_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/thread_audio_player_provider.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/back_to_top_button.dart';
import '../../../../shared/widgets/cover_hero.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../../domain/pantun_models.dart';
import '../providers/pantun_providers.dart';
import '../widgets/pantun_card.dart';
import '../widgets/pantun_delete_sheet.dart';
import '../widgets/pantun_report_sheet.dart';

/// Feed pantun 4 baris (kategori Eksplorasi Pantun) + kolom cari isi pantun.
class PantunFeedPage extends HookConsumerWidget {
  const PantunFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(pantunFeedProvider);
    final scroll = useScrollController();

    // Cari: raw = isi field, query = versi debounce (hindari request per ketik).
    final searchController = useTextEditingController();
    final rawQuery = useState('');
    final query = useState('');
    useEffect(() {
      final next = rawQuery.value.trim();
      if (next == query.value) return null;
      final timer = Timer(const Duration(milliseconds: 350), () {
        query.value = next;
      });
      return timer.cancel;
    }, [rawQuery.value]);

    useEffect(() {
      void listener() {
        if (!scroll.hasClients) return;
        if (searchController.text.trim().isNotEmpty) return;
        if (scroll.position.maxScrollExtent - scroll.position.pixels < 200) {
          ref.read(pantunFeedProvider.notifier).loadMore();
        }
      }

      scroll.addListener(listener);
      return () => scroll.removeListener(listener);
    }, [scroll]);

    final searching = query.value.isNotEmpty;
    final myUserId = ref.watch(authStatusProvider).value?.userId;

    Future<void> deletePantun(Pantun pantun) async {
      final ok = await showPantunDeleteSheet(
        context,
        title: l10n.pantunDeleteConfirmTitle,
        subtitle: l10n.pantunDeleteFeedConfirmBody,
      );
      if (!ok || !context.mounted) return;
      final error = await ref
          .read(pantunFeedProvider.notifier)
          .deletePantun(pantun);
      if (!context.mounted) return;
      if (error == null) {
        showFToast(
          context: context,
          title: Text(l10n.pantunDeletedToast),
          variant: FToastVariant.primary,
        );
        return;
      }
      await showAppErrorSheet(context, message: error);
    }

    final searchAsync = searching
        ? ref.watch(pantunSearchProvider(query.value))
        : null;

    Future<void> refresh() async {
      if (query.value.isNotEmpty) {
        final q = query.value;
        ref.invalidate(pantunSearchProvider(q));
        try {
          await ref.read(pantunSearchProvider(q).future);
        } catch (_) {}
        return;
      }
      await ref.read(pantunFeedProvider.notifier).refresh();
    }

    final content = searching
        ? _searchSlivers(context, l10n, searchAsync!)
        : _feedSlivers(
            context,
            ref,
            l10n,
            async,
            myUserId: myUserId,
            onDelete: deletePantun,
          );

    return StopThreadAudioOnLeave(
      action: ThreadAudioLeaveAction.stop,
      child: FScaffold(
        childPad: false,
        footer: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: FButton(
              onPress: () async {
                final auth = await ref.read(authStatusProvider.future);
                if (!auth.isAuth) {
                  if (context.mounted) {
                    await showAppErrorSheet(
                      context,
                      message: l10n.pantunWriteLoginRequired,
                    );
                  }
                  return;
                }
                if (context.mounted) {
                  await context.push('/entertainment/pantun/create');
                }
              },
              child: Text(l10n.pantunWrite),
            ),
          ),
        ),
        child: ProfileHeroShell(
          showBack: true,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(EntertainmentRouter.hub.path),
          backLabel: l10n.commonBack,
          coverHeight: ProfileIdentityHeader.coverHeightOf(
            ProfileHeaderVariant.compact,
            MediaQuery.sizeOf(context).width,
          ),
          title: l10n.pantunTitle,
          compactActions: true,
          scrollView: ScrollWithBackToTop(
            // Sedikit lebih tinggi: footer "Tulis pantun" di bawah body.
            controller: scroll,
            bottom: 8,
            child: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                controller: scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ..._pantunCoverSlivers(context, l10n),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: FTextField(
                        control: FTextFieldControl.managed(
                          controller: searchController,
                          onChange: (value) => rawQuery.value = value.text,
                        ),
                        hint: l10n.pantunSearchHint,
                        clearable: (value) => value.text.isNotEmpty,
                        textInputAction: TextInputAction.search,
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
                  ...content,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _pantunCoverSlivers(BuildContext context, AppLocalizations l10n) {
  final barOffset =
      MediaQuery.paddingOf(context).top + ProfileHeroShell.barHeight;
  return [
    SliverPersistentHeader(
      pinned: true,
      delegate: ProfileBarClearanceHeader(height: barOffset),
    ),
    SliverToBoxAdapter(
      child: OverlapAboveBox(
        overlap: barOffset,
        child: CoverHero(
          asset: 'assets/images/pantun_hero.webp',
          title: l10n.pantunTitle,
          subtitle: l10n.pantunListSubtitle,
          semanticLabel: l10n.pantunHeroSemantics,
        ),
      ),
    ),
  ];
}

/// Hasil pencarian: induk langsung ke detail, balasan ke induk + auto-scroll.
List<Widget> _searchSlivers(
  BuildContext context,
  AppLocalizations l10n,
  AsyncValue<List<Pantun>> async,
) {
  return async.when(
    loading: () => const [SliverToBoxAdapter(child: _FeedSkeleton())],
    error: (e, _) => [
      SliverFillRemaining(
        hasScrollBody: false,
        child: _MessageList(
          icon: FLucideIcons.circleAlert,
          title: e is PantunFailure ? e.message : l10n.pantunSearchFailed,
        ),
      ),
    ],
    data: (items) {
      if (items.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _MessageList(
                shrink: true,
                icon: FLucideIcons.searchX,
                title: l10n.pantunSearchEmptyTitle,
                subtitle: l10n.pantunSearchEmptyBody,
              ),
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          sliver: SliverList.list(
            children: [
              for (final p in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PantunCard(
                    pantun: p,
                    footer: p.parentId == null
                        ? null
                        : Text(
                            l10n.pantunReplies,
                            style: context.theme.typography.body.sm.copyWith(
                              fontSize: 11,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                    onTap: () => context.push(
                      p.parentId == null
                          ? '/entertainment/pantun/${p.id}'
                          // Balasan: buka thread induk, lalu auto-scroll ke sini.
                          : '/entertainment/pantun/${p.parentId}?reply=${p.id}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ];
    },
  );
}

List<Widget> _feedSlivers(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  AsyncValue<PantunFeedState> async, {
  required String? myUserId,
  required Future<void> Function(Pantun pantun) onDelete,
}) {
  return async.when(
    loading: () => const [SliverToBoxAdapter(child: _FeedSkeleton())],
    error: (e, _) => [
      SliverFillRemaining(
        hasScrollBody: false,
        child: _MessageList(
          icon: FLucideIcons.circleAlert,
          title: e is PantunFailure ? e.message : l10n.pantunLoadFailedShort,
        ),
      ),
    ],
    data: (state) {
      if (state.items.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _MessageList(
                shrink: true,
                icon: FLucideIcons.feather,
                title: l10n.pantunEmptyTitle,
                subtitle: l10n.pantunEmptyBody,
              ),
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          sliver: SliverList.list(
            children: [
              for (final p in state.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PantunCard(
                    pantun: p,
                    onTap: () => context.push('/entertainment/pantun/${p.id}'),
                    onVoteToggle: (pantun, value) => ref
                        .read(pantunFeedProvider.notifier)
                        .toggleVote(pantun, value),
                    footer: p.userId == myUserId
                        ? PantunActionRow.delete(onDelete: () => onDelete(p))
                        : PantunActionRow.report(
                            onReport: () => reportPantunFromUi(
                              context,
                              ref,
                              targetType: 'pantun',
                              targetId: p.id,
                            ),
                          ),
                  ),
                ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: FCircularProgress(size: .sm)),
                ),
            ],
          ),
        ),
      ];
    },
  );
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.icon,
    required this.title,
    this.subtitle,
    this.shrink = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// true = dipakai sebagai child ListView (tanpa Expanded/ListView sendiri).
  final bool shrink;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final content = [
      if (!shrink) const Gap(64),
      Icon(icon, size: 40, color: theme.colors.mutedForeground),
      const Gap(10),
      Text(
        title,
        textAlign: TextAlign.center,
        style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
      ),
      if (subtitle != null) ...[
        const Gap(6),
        Text(
          subtitle!,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    ];
    return Column(children: content);
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  static final _sample = Pantun(
    id: 'id',
    userId: 'u',
    username: 'penulis',
    displayName: null,
    avatarUrl: null,
    parentId: null,
    language: 'id',
    themeId: null,
    rhymeScheme: 'ABAB',
    lines: [
      'Baris pertama pantun',
      'Baris kedua pantun',
      'Baris ketiga pantun',
      'Baris keempat pantun',
    ],
    status: 'published',
    createdAt: DateTime(2026),
    updatedAt: null,
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PantunCard(pantun: _sample),
            ),
          ),
        ),
      ),
    );
  }
}
