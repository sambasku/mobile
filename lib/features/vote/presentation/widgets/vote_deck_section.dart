import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/widgets/busy_aware_icon.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/failures/vote_failure.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../dictionary/presentation/providers/audio_player_controller.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../providers/vote_deck_providers.dart';
import '../providers/vote_submit_queue.dart';
import 'vote_deck_swipe_card.dart';
import 'vote_deck_word_card.dart';

/// Aksi yang sedang diproses di deck vote (spinner hanya di rewind).
enum VotePendingAction { rewind }

/// #109: detail pesan error deck - VoteFailure pakai message asli
/// (errorCode menyusul), exception lain teks generik (bukan toString()
/// yang bocor nama class ter-obfuscate).
String _deckErrorDetail(Object error) => switch (error) {
      VoteFailure(:final message, :final errorCode) =>
        errorCode != null ? '$message ($errorCode)' : message,
      _ => '',
    };

/// Section deck nilai kata di tab Kontribusi.
///
/// Loading / ganti kartu / action bar mengikuti pola sesi tinjau
/// (`ReviewSessionPage`): skeleton kerangka kartu, AnimatedSwitcher,
/// footer ikon downvote · lewati · upvote · rewind.
class VoteDeckSection extends ConsumerStatefulWidget {
  const VoteDeckSection({super.key});

  @override
  ConsumerState<VoteDeckSection> createState() => _VoteDeckSectionState();
}

class _VoteDeckSectionState extends ConsumerState<VoteDeckSection> {
  VotePendingAction? _pendingAction;
  bool _loggedView = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider);
    final deck = ref.watch(voteDeckControllerProvider).value;
    final remaining = deck == null || deck.items.isEmpty
        ? null
        : 'sisa ${deck.items.length}${deck.hasMore ? '+' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bantu nilai agar arti kata lebih akurat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            if (remaining != null) ...[
              const Gap(8),
              Text(
                remaining,
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const Gap(8),
        Expanded(
          child: auth.when(
            loading: () => const _VoteDeckCardPlaceholder(),
            error: (_, _) => const _GuestDeck(),
            data: (status) => status.isAuth
                ? _AuthDeck(
                    pendingAction: _pendingAction,
                    onPendingAction: (action) =>
                        setState(() => _pendingAction = action),
                    onDeckVisible: () {
                      if (_loggedView) return;
                      _loggedView = true;
                      AnalyticsService.instance.log(AnalyticsEvents.voteDeckView);
                    },
                  )
                : const _GuestDeck(),
          ),
        ),
      ],
    );
  }
}

class _GuestDeck extends ConsumerWidget {
  const _GuestDeck();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samples = ref.watch(voteDeckGuestSamplesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: samples.when(
            loading: () => const _VoteDeckCardPlaceholder(),
            error: (_, _) => const _VoteDeckCardPlaceholder(),
            data: (items) {
              if (items.isEmpty) {
                return const _VoteDeckCardPlaceholder(enabled: false);
              }
              final w = items.first;
              return _CardShell(
                child: VoteDeckWordFace(
                  lemma: w.lemma,
                  sense: w.sense,
                  wordType: w.wordType,
                ),
              );
            },
          ),
        ),
        const Gap(12),
        const FAlert(
          title: Text('Masuk dulu untuk menilai kata'),
          icon: Icon(FLucideIcons.logIn),
        ),
        const Gap(8),
        FButton(
          onPress: () => context.push('/login'),
          child: const Text('Masuk'),
        ),
        const Gap(12),
      ],
    );
  }
}

class _AuthDeck extends ConsumerStatefulWidget {
  const _AuthDeck({
    required this.pendingAction,
    required this.onPendingAction,
    required this.onDeckVisible,
  });

  final VotePendingAction? pendingAction;
  final ValueChanged<VotePendingAction?> onPendingAction;
  final VoidCallback onDeckVisible;

  @override
  ConsumerState<_AuthDeck> createState() => _AuthDeckState();
}

class _AuthDeckState extends ConsumerState<_AuthDeck> {
  bool get _rewinding => widget.pendingAction == VotePendingAction.rewind;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDeckVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final async = ref.watch(voteDeckControllerProvider);

    ref.listen(voteSubmitQueueProvider, (prev, next) {
      if (next.errorSeq == 0) return;
      if (prev != null && prev.errorSeq == next.errorSeq) return;
      final failed = next.failedItem;
      if (failed != null) {
        ref.read(voteDeckControllerProvider.notifier).reinsertFront(failed);
      }
      if (!context.mounted) return;
      final message = next.errorMessage ?? 'Gagal menyimpan penilaian';
      showFToast(context: context, title: Text(message));
    });

    return async.when(
      // Kerangka kartu (bukan spinner) - sama pola sesi tinjau.
      loading: () => const _VoteDeckCardPlaceholder(),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FAlert(
            variant: FAlertVariant.destructive,
            title: Text(
              'Gagal memuat antrean penilaian. Ketuk refresh di atas untuk coba lagi.',
            ),
            icon: Icon(FLucideIcons.circleAlert),
          ),
          // #109: pesan failure backend, atau teks generik utk exception
          // tak dikenal - jangan toString() mentah (bocor nama class
          // ter-obfuscate seperti "Instance of 'tTb'").
          if (_deckErrorDetail(error).isNotEmpty) ...[
            const Gap(6),
            Text(
              _deckErrorDetail(error),
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  FLucideIcons.circleCheck,
                  size: 36,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(10),
                Text(
                  'Kamu sudah menilai semua kata di antrean. Terima kasih membantu warga lain.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state.canRewind) ...[
                  const Gap(16),
                  _VoteDeckActionBar(
                    pendingAction: widget.pendingAction,
                    canRewind: true,
                    onDisagree: null,
                    onSkip: null,
                    onAgree: null,
                    onRewind: () => _rewind(context, ref),
                  ),
                ],
              ],
            ),
          );
        }

        final item = state.items.first;
        if (state.items.length > 1) _prefetchDetail(state.items[1].id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                // expand: Stack AnimatedSwitcher memberi constraint longgar.
                child: SizedBox.expand(
                  key: ValueKey('card-${item.id}'),
                  child: VoteDeckSwipeCard(
                    itemKey: item.id,
                    enabled: !_rewinding,
                    onSwiped: (dir) =>
                        _cast(context, ref, item: item, direction: dir),
                    child: VoteDeckWordCard(
                      item: item,
                      onOpenDetail: _rewinding
                          ? null
                          : () => _openDetail(context, item),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            _VoteDeckActionBar(
              pendingAction: widget.pendingAction,
              canRewind: state.canRewind,
              onDisagree: _rewinding
                  ? null
                  : () => _castBar(
                        context,
                        ref,
                        item: item,
                        direction: VoteDeckSwipeDirection.disagree,
                      ),
              onSkip: _rewinding
                  ? null
                  : () => _castBar(
                        context,
                        ref,
                        item: item,
                        direction: VoteDeckSwipeDirection.skip,
                      ),
              onAgree: _rewinding
                  ? null
                  : () => _castBar(
                        context,
                        ref,
                        item: item,
                        direction: VoteDeckSwipeDirection.agree,
                      ),
              onRewind: () => _rewind(context, ref),
              // Kartu tidak digeser: deck keepAlive, kembali ke kata yang sama.
              onFix: () => context.push('/suggest-edit/${item.id}'),
            ),
          ],
        );
      },
    );
  }

  // ponytail: wordDetailProvider keepAlive, jadi cache tumbuh satu entri per
  // kata yang dinilai selama sesi. Kalau memori jadi masalah, pakai varian
  // autoDispose khusus deck.
  void _prefetchDetail(String wordId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(wordDetailProvider(wordId).future).ignore();
    });
  }

  /// Detail kata (komentar, riwayat, …). Vote di detail = kartu dianggap
  /// sudah dinilai; logikanya di controller karena widget ini dispose
  /// selama route root terbuka.
  Future<void> _openDetail(BuildContext context, VoteDeckItem item) async {
    ref.read(wordDetailAudioPlayerProvider(item.id).notifier).stop();
    final deck = ref.read(voteDeckControllerProvider.notifier);
    final dropped = await deck.openDetail(
      item,
      () => context.push(
        DictionaryRouter.detail.path.replaceFirst(':id', item.id),
      ),
    );
    // Context widget ini mungkin sudah dispose: toast lewat navigator root
    // (di bawah FToaster).
    final root = AppRouter.rootNavigatorKey.currentContext;
    if (!dropped || root == null || !root.mounted) return;
    showFToast(
      context: root,
      title: const Text('Penilaian dari detail tersimpan'),
    );
  }

  /// Tap action bar: getar dulu, lalu jalankan cast yang sama dengan swipe.
  /// Bukan haptic di dalam [_cast]: jalur swipe sudah dapat getar di
  /// [SwipeDecisionCard._commit] - dua-duanya jalan = getar ganda.
  void _castBar(
    BuildContext context,
    WidgetRef ref, {
    required VoteDeckItem item,
    required VoteDeckSwipeDirection direction,
  }) {
    unawaited(HapticFeedback.lightImpact());
    _cast(context, ref, item: item, direction: direction);
  }

  Future<bool> _cast(
    BuildContext context,
    WidgetRef ref, {
    required VoteDeckItem item,
    required VoteDeckSwipeDirection direction,
  }) async {
    if (_rewinding) return false;
    // AnimatedSwitcher menahan kartu lama ~220ms; audio berhenti saat swipe.
    ref.read(wordDetailAudioPlayerProvider(item.id).notifier).stop();

    if (direction == VoteDeckSwipeDirection.skip) {
      ref.read(voteDeckControllerProvider.notifier).skipAndAdvance(item);
      return true;
    }

    final value = direction == VoteDeckSwipeDirection.agree ? 1 : -1;
    ref.read(voteDeckControllerProvider.notifier).castOptimistic(
          item: item,
          value: value,
        );

    AnalyticsService.instance.log(
      AnalyticsEvents.voteDeckSwipe,
      params: {
        'direction': direction == VoteDeckSwipeDirection.agree
            ? 'right'
            : 'left',
        'word_id': item.id,
      },
    );
    return true;
  }

  Future<void> _rewind(BuildContext context, WidgetRef ref) async {
    if (_rewinding) return;
    widget.onPendingAction(VotePendingAction.rewind);
    final failure =
        await ref.read(voteDeckControllerProvider.notifier).rewind();
    if (!context.mounted) {
      widget.onPendingAction(null);
      return;
    }
    widget.onPendingAction(null);
    if (failure != null) {
      showFToast(context: context, title: Text(failure.message));
      return;
    }
    showFToast(
      context: context,
      title: const Text('Kartu sebelumnya dikembalikan.'),
    );
  }
}

/// Action bar: [Perbaiki] [undo][skip][downvote][upvote] - pola sama dengan
/// action bar sesi tinjau (Koreksi di kiri, vote sejajar di kanan).
class _VoteDeckActionBar extends StatelessWidget {
  const _VoteDeckActionBar({
    required this.pendingAction,
    required this.canRewind,
    required this.onDisagree,
    required this.onSkip,
    required this.onAgree,
    required this.onRewind,
    this.onFix,
  });

  final VotePendingAction? pendingAction;
  final bool canRewind;

  /// Buka form usul perubahan untuk kartu aktif; null = tombol disembunyikan.
  final VoidCallback? onFix;
  final VoidCallback? onDisagree;
  final VoidCallback? onSkip;
  final VoidCallback? onAgree;
  final VoidCallback onRewind;

  bool get _rewinding => pendingAction == VotePendingAction.rewind;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        // Horizontal 0: sejajar tepi kartu dan tombol Menu kontribusi.
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
        child: Row(
          children: [
            Expanded(
              child: onFix == null
                  ? const SizedBox.shrink()
                  // Layar sempit (sekitar 320dp): ikon saja, bukan "P...".
                  : LayoutBuilder(
                      builder: (context, constraints) => constraints.maxWidth < 100
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: FButton.icon(
                                variant: FButtonVariant.outline,
                                size: FButtonSizeVariant.sm,
                                semanticsLabel: 'Perbaiki kata ini',
                                onPress: _rewinding ? null : onFix,
                                child: const Icon(FLucideIcons.pencil),
                              ),
                            )
                          : FButton(
                              variant: FButtonVariant.outline,
                              size: FButtonSizeVariant.sm,
                              semanticsLabel: 'Perbaiki kata ini',
                              onPress: _rewinding ? null : onFix,
                              prefix: const Icon(FLucideIcons.pencil),
                              child: const Text('Perbaiki'),
                            ),
                    ),
            ),
            const Gap(8),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: _rewinding
                  ? 'Memproses…'
                  : 'Kembali ke kartu sebelumnya',
              onPress: _rewinding || !canRewind ? null : onRewind,
              child: BusyAwareIcon(
                loading: _rewinding,
                icon: const Icon(FLucideIcons.undo),
              ),
            ),
            const Gap(8),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: 'Lewati',
              onPress: _rewinding || onSkip == null ? null : onSkip,
              child: const Icon(FLucideIcons.skipForward),
            ),
            const Gap(12),
            // Pasangan downvote / upvote sejajar (mirip VoteButtons).
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: 'Perlu dicek ulang',
              onPress: _rewinding || onDisagree == null ? null : onDisagree,
              child: Icon(
                FLucideIcons.arrowBigDown,
                color: theme.colors.destructive,
              ),
            ),
            const Gap(8),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: 'Sudah pas',
              onPress: _rewinding || onAgree == null ? null : onAgree,
              child: Icon(
                FLucideIcons.arrowBigUp,
                color: theme.colors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

/// Kerangka kartu saat antrean masih dimuat / penilaian sedang dikirim.
class _VoteDeckCardPlaceholder extends StatelessWidget {
  const _VoteDeckCardPlaceholder({this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colors.border),
      ),
      child: SizedBox.expand(
        child: SkeletonizerConfig(
          data: SkeletonizerConfigData(effect: shimmer),
          child: IgnorePointer(
            child: Skeletonizer(
              enabled: enabled,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lemma contoh skeleton',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Gap(12),
                    Text(
                      'Ringkasan arti atau terjemahan agar kerangka kartu mendekati layout asli.',
                      textAlign: TextAlign.center,
                    ),
                    Gap(10),
                    Text('jenis kata', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
