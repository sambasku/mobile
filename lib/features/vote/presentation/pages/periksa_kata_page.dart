import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/header_action_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../periksa_kata_router.dart';
import '../providers/periksa_kata_providers.dart';
import '../widgets/vote_buttons.dart';
import '../widgets/vote_deck_word_card.dart';

/// Feed Periksa Kata: makna published belum verified.
///
/// Tap lemma membuka [DictionaryRouter.detail] (`/words/:id?meaning=`) -
/// halaman detail kata yang sama (termasuk status menunggu pengecekan).
class PeriksaKataPage extends ConsumerStatefulWidget {
  const PeriksaKataPage({super.key});

  @override
  ConsumerState<PeriksaKataPage> createState() => _PeriksaKataPageState();
}

class _PeriksaKataPageState extends ConsumerState<PeriksaKataPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(periksaKataFeedControllerProvider.notifier).setQuery(text);
    });
  }

  Future<void> _refresh() async {
    await ref.read(periksaKataFeedControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.feedContributePeriksaKata),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.history, size: kHeaderActionIconSize),
            onPress: () => context.push(PeriksaKataRouter.history.path),
          ),
          FHeaderAction(
            icon: const Icon(
              FLucideIcons.refreshCw,
              size: kHeaderActionIconSize,
            ),
            onPress: _refresh,
          ),
        ],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => _LoginGate(l10n: l10n),
        data: (status) => status.isAuth
            ? _FeedBody(onSearchChanged: _onSearchChanged, onRefresh: _refresh)
            : _LoginGate(l10n: l10n),
      ),
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.clipboardCheck,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(12),
            Text(
              l10n.periksaKataLoginPrompt,
              textAlign: TextAlign.center,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(16),
            FButton(
              onPress: () => context.push('/login'),
              child: Text(l10n.voteDeckLoginCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({
    required this.onSearchChanged,
    required this.onRefresh,
  });

  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(periksaKataFeedControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(
            onChange: (value) => onSearchChanged(value.text),
          ),
          hint: l10n.periksaKataSearchHint,
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: async.when(
              loading: () => Skeletonizer(
                child: ListView(
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Bone(
                        width: double.infinity,
                        height: 160,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
              error: (err, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const Gap(48),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(16),
                  Center(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: onRefresh,
                      child: Text(l10n.commonRetry),
                    ),
                  ),
                ],
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const Gap(48),
                      Text(
                        state.q.isEmpty
                            ? l10n.periksaKataEmpty
                            : l10n.periksaKataSearchEmpty,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  );
                }

                return _FeedList(
                  items: state.items,
                  hasMore: state.hasMore,
                  sessionVotes: state.sessionVotes,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedList extends ConsumerStatefulWidget {
  const _FeedList({
    required this.items,
    required this.hasMore,
    required this.sessionVotes,
  });

  final List<VoteDeckItem> items;
  final bool hasMore;
  final Map<String, int> sessionVotes;

  @override
  ConsumerState<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<_FeedList> {
  final _scroll = ScrollController();
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _maybeLoadMore() async {
    if (_loadingMore || !widget.hasMore || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels >= 200) {
      return;
    }
    _loadingMore = true;
    final failure = await ref
        .read(periksaKataFeedControllerProvider.notifier)
        .loadMore();
    if (mounted && failure != null) {
      showFToast(context: context, title: Text(failure.message));
    }
    _loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return _PeriksaKataCard(
          item: item,
          sessionVote: widget.sessionVotes[item.id],
        );
      },
    );
  }
}

class _PeriksaKataCard extends ConsumerWidget {
  const _PeriksaKataCard({
    required this.item,
    required this.sessionVote,
  });

  final VoteDeckItem item;
  final int? sessionVote;

  void _openDetail(BuildContext context) {
    // Halaman detail kata yang sama (published + menunggu pengecekan).
    final path = DictionaryRouter.detail.path.replaceFirst(':id', item.wordId);
    context.push('$path?meaning=${Uri.encodeQueryComponent(item.id)}');
  }

  Future<void> _onVote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      context.push('/login');
      return;
    }
    if (sessionVote != null) return;

    final failure = await ref
        .read(periksaKataFeedControllerProvider.notifier)
        .vote(item: item, value: value);
    if (!context.mounted) return;
    if (failure != null) {
      showFToast(context: context, title: Text(failure.message));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final voted = sessionVote != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoteDeckMeaningFace(
              lemma: item.lemma,
              sense: item.sense,
              wordTypeLabel: item.wordTypeLabel,
              wordClassLabel: item.wordClassLabel,
              orderIndex: item.orderIndex,
              meaningCount: item.meaningCount,
              pronunciationValue: item.pronunciationValue,
              hasAudio: item.hasAudio,
              onOpenDetail: () => _openDetail(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  if (voted) ...[
                    Text(
                      sessionVote == 1
                          ? l10n.periksaKataVotedAgree
                          : l10n.periksaKataVotedDisagree,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                  ],
                  VoteButtons(
                    upvotes: item.upvotes,
                    downvotes: item.downvotes,
                    myVote: sessionVote,
                    busy: voted,
                    onVote: (value) => _onVote(context, ref, value),
                  ),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.periksaKataDisagree,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(24),
                      Text(
                        l10n.periksaKataAgree,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
