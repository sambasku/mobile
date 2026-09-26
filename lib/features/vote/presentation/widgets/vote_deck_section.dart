import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../providers/vote_deck_providers.dart';
import 'vote_deck_swipe_card.dart';

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
  bool _busy = false;
  bool _loggedView = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bantu nilai agar arti kata lebih akurat',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        Expanded(
          child: auth.when(
            loading: () => const _VoteDeckCardPlaceholder(),
            error: (_, _) => const _GuestDeck(),
            data: (status) => status.isAuth
                ? _AuthDeck(
                    busy: _busy,
                    onBusy: (v) => setState(() => _busy = v),
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
        samples.when(
          loading: () => const _VoteDeckCardPlaceholder(),
          error: (_, _) => const _VoteDeckCardPlaceholder(),
          data: (items) {
            if (items.isEmpty) {
              return const _VoteDeckCardPlaceholder(enabled: false);
            }
            final w = items.first;
            return _CardShell(
              child: _WordCardFace(
                lemma: w.lemma,
                sense: w.sense,
                wordType: w.wordType,
              ),
            );
          },
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
      ],
    );
  }
}

class _AuthDeck extends ConsumerStatefulWidget {
  const _AuthDeck({
    required this.busy,
    required this.onBusy,
    required this.onDeckVisible,
  });

  final bool busy;
  final ValueChanged<bool> onBusy;
  final VoidCallback onDeckVisible;

  @override
  ConsumerState<_AuthDeck> createState() => _AuthDeckState();
}

class _AuthDeckState extends ConsumerState<_AuthDeck> {
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
          if (error.toString().isNotEmpty) ...[
            const Gap(6),
            Text(
              error.toString(),
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
                    busy: widget.busy,
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
        final remainingHint = state.hasMore
            ? '${state.items.length}+'
            : '${state.items.length}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.busy
                  ? 'Menyimpan penilaian…'
                  : 'Nilai · sisa $remainingHint',
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  // Saat submit: kartu sudah keluar layar → isi slot dengan
                  // skeleton supaya tidak kosong diam (beda dari sesi tinjau
                  // yang preload detail berikutnya).
                  child: widget.busy
                      ? const _VoteDeckCardPlaceholder(
                          key: ValueKey('submitting'),
                        )
                      : SizedBox(
                          key: ValueKey('card-${item.id}'),
                          height: 240,
                          child: VoteDeckSwipeCard(
                            itemKey: item.id,
                            enabled: true,
                            onSwiped: (dir) =>
                                _cast(context, ref, item: item, direction: dir),
                            child: _WordCardFace(
                              lemma: item.lemma,
                              sense: item.sense,
                              wordType: item.wordType,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const Gap(10),
            _VoteDeckActionBar(
              busy: widget.busy,
              canRewind: state.canRewind,
              onDisagree: () => _cast(
                context,
                ref,
                item: item,
                direction: VoteDeckSwipeDirection.disagree,
              ),
              onSkip: () => _cast(
                context,
                ref,
                item: item,
                direction: VoteDeckSwipeDirection.skip,
              ),
              onAgree: () => _cast(
                context,
                ref,
                item: item,
                direction: VoteDeckSwipeDirection.agree,
              ),
              onRewind: () => _rewind(context, ref),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _cast(
    BuildContext context,
    WidgetRef ref, {
    required VoteDeckItem item,
    required VoteDeckSwipeDirection direction,
  }) async {
    if (widget.busy) return false;

    // Skip lokal - tanpa busy/skeleton (bukan submit server).
    if (direction == VoteDeckSwipeDirection.skip) {
      ref.read(voteDeckControllerProvider.notifier).skipAndAdvance(item);
      return true;
    }

    widget.onBusy(true);
    final value = direction == VoteDeckSwipeDirection.agree ? 1 : -1;
    final failure = await ref
        .read(voteDeckControllerProvider.notifier)
        .castAndAdvance(item: item, value: value);

    if (!context.mounted) {
      widget.onBusy(false);
      return failure == null;
    }
    if (failure != null) {
      widget.onBusy(false);
      showFToast(context: context, title: Text(failure.message));
      return false;
    }

    AnalyticsService.instance.log(
      AnalyticsEvents.voteDeckSwipe,
      params: {
        'direction': direction == VoteDeckSwipeDirection.agree
            ? 'right'
            : 'left',
        'word_id': item.id,
      },
    );

    widget.onBusy(false);
    showFToast(
      context: context,
      title: Text(
        direction == VoteDeckSwipeDirection.agree
            ? 'Masuk akal - tersimpan.'
            : 'Kurang pas - tersimpan.',
      ),
    );
    return true;
  }

  Future<void> _rewind(BuildContext context, WidgetRef ref) async {
    if (widget.busy) return;
    widget.onBusy(true);
    final failure =
        await ref.read(voteDeckControllerProvider.notifier).rewind();
    if (!context.mounted) {
      widget.onBusy(false);
      return;
    }
    widget.onBusy(false);
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

/// Action bar: [undo][skip][downvote][upvote] - vote sejajar di kanan.
class _VoteDeckActionBar extends StatelessWidget {
  const _VoteDeckActionBar({
    required this.busy,
    required this.canRewind,
    required this.onDisagree,
    required this.onSkip,
    required this.onAgree,
    required this.onRewind,
  });

  final bool busy;
  final bool canRewind;
  final VoidCallback? onDisagree;
  final VoidCallback? onSkip;
  final VoidCallback? onAgree;
  final VoidCallback onRewind;

  Widget _busyOr(Widget icon) {
    if (!busy) return icon;
    return const SizedBox(
      width: 18,
      height: 18,
      child: FCircularProgress(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Pilih penilaian',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(8),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: 'Kembali ke kartu sebelumnya',
              onPress: busy || !canRewind ? null : onRewind,
              child: _busyOr(const Icon(FLucideIcons.undo)),
            ),
            const Gap(8),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: busy ? 'Memproses…' : 'Lewati',
              onPress: busy || onSkip == null ? null : onSkip,
              child: _busyOr(const Icon(FLucideIcons.skipForward)),
            ),
            const Gap(12),
            // Pasangan downvote / upvote sejajar (mirip VoteButtons).
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: busy ? 'Memproses…' : 'Kurang pas',
              onPress: busy || onDisagree == null ? null : onDisagree,
              child: _busyOr(
                Icon(
                  FLucideIcons.arrowBigDown,
                  color: theme.colors.destructive,
                ),
              ),
            ),
            const Gap(4),
            FButton.icon(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              semanticsLabel: busy ? 'Memproses…' : 'Masuk akal',
              onPress: busy || onAgree == null ? null : onAgree,
              child: _busyOr(
                Icon(
                  FLucideIcons.arrowBigUp,
                  color: theme.colors.success,
                ),
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
        child: SizedBox(height: 200, child: child),
      ),
    );
  }
}

/// Kerangka kartu saat antrean masih dimuat / penilaian sedang dikirim.
class _VoteDeckCardPlaceholder extends StatelessWidget {
  const _VoteDeckCardPlaceholder({super.key, this.enabled = true});

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
      child: SizedBox(
        height: 240,
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
                      'Ringkasan arti atau padanan agar kerangka kartu mendekati layout asli.',
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

class _WordCardFace extends StatelessWidget {
  const _WordCardFace({
    required this.lemma,
    required this.sense,
    required this.wordType,
  });

  final String lemma;
  final String? sense;
  final String wordType;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lemma,
            style: theme.typography.xl.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (sense != null && sense!.trim().isNotEmpty) ...[
            const Gap(10),
            Text(
              sense!,
              style: theme.typography.md.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (wordType.isNotEmpty) ...[
            const Gap(12),
            Text(
              wordType,
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
