import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../my_votes/domain/entities/my_vote_item.dart';
import '../providers/periksa_kata_providers.dart';

/// Riwayat pemeriksaan makna (vote meaning + community_status).
class PeriksaKataHistoryPage extends ConsumerStatefulWidget {
  const PeriksaKataHistoryPage({super.key});

  @override
  ConsumerState<PeriksaKataHistoryPage> createState() =>
      _PeriksaKataHistoryPageState();
}

class _PeriksaKataHistoryPageState
    extends ConsumerState<PeriksaKataHistoryPage> {
  Timer? _debounce;
  int _tabIndex = 0;

  static const _statuses = <String?>[null, 'pending', 'verified', 'rejected'];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(periksaKataHistoryControllerProvider.notifier).setQuery(text);
    });
  }

  void _onTabChanged(int index) {
    setState(() => _tabIndex = index);
    ref
        .read(periksaKataHistoryControllerProvider.notifier)
        .setCommunityStatus(_statuses[index]);
  }

  Future<void> _refresh() async {
    await ref.read(periksaKataHistoryControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.periksaKataHistoryTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.periksaKataLoginPrompt)),
        data: (status) {
          if (!status.isAuth) {
            return Center(
              child: FButton(
                onPress: () => context.push('/login'),
                child: Text(l10n.voteDeckLoginCta),
              ),
            );
          }

          final async = ref.watch(periksaKataHistoryControllerProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (value) => _onSearchChanged(value.text),
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
              const Gap(8),
              FTabs(
                expands: false,
                style: .delta(spacing: 0),
                control: .lifted(index: _tabIndex, onChange: _onTabChanged),
                children: [
                  for (final label in [
                    l10n.periksaKataFilterAll,
                    l10n.periksaKataFilterPending,
                    l10n.periksaKataFilterVerified,
                    l10n.periksaKataFilterRejected,
                  ])
                    FTabEntry.entry(
                      label: Text(label),
                      child: const SizedBox.shrink(),
                    ),
                ],
              ),
              const Gap(8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: async.when(
                    loading: () => const Center(child: FCircularProgress()),
                    error: (err, _) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const Gap(48),
                        Text(err.toString(), textAlign: TextAlign.center),
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
                                  ? l10n.periksaKataHistoryEmpty
                                  : l10n.periksaKataSearchEmpty,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        );
                      }

                      return TileGroupList<MyVoteItem>(
                        items: state.items,
                        hasMore: state.hasMore,
                        onLoadMore: () async {
                          final failure = await ref
                              .read(
                                periksaKataHistoryControllerProvider.notifier,
                              )
                              .loadMore();
                          if (failure != null && context.mounted) {
                            showFToast(
                              context: context,
                              title: Text(failure.message),
                            );
                          }
                        },
                        tileBuilder: (context, item) =>
                            _HistoryTile(item: item),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final MyVoteItem item;

  String _statusLabel(AppLocalizations l10n) {
    return switch (item.communityStatus) {
      'verified' => l10n.periksaKataFilterVerified,
      'rejected' => l10n.periksaKataFilterRejected,
      'pending' => l10n.periksaKataFilterPending,
      _ => l10n.periksaKataFilterPending,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lemma = item.word?.lemma ?? '-';
    final choice = item.value == 1
        ? l10n.periksaKataAgree
        : l10n.periksaKataDisagree;

    return FTile(
      title: Text(lemma),
      subtitle: Text(
        '$choice · ${_statusLabel(l10n)} · ${formatDateTimeIso(item.votedAt)}',
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: item.word == null
          ? null
          : () {
              final path = DictionaryRouter.detail.path.replaceFirst(
                ':id',
                item.word!.id,
              );
              context.push(
                '$path?meaning=${Uri.encodeQueryComponent(item.targetId)}',
              );
            },
    );
  }
}
