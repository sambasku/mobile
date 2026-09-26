import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/review_access.dart';
import '../providers/review_providers.dart';
import '../widgets/review_correct_form.dart';
import '../widgets/review_entity_preview.dart';
import '../widgets/review_swipe_card.dart';
import 'review_forbidden_page.dart';

/// Sesi tinjau satu layar: preview + aksi + koreksi inline, auto-advance.
class ReviewSessionPage extends ConsumerStatefulWidget {
  const ReviewSessionPage({
    super.key,
    this.startId,
    this.wordId,
    this.openCorrect = false,
  });

  final String? startId;
  final String? wordId;
  final bool openCorrect;

  @override
  ConsumerState<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends ConsumerState<ReviewSessionPage> {
  bool _busy = false;
  bool _correctMode = false;
  bool _bootstrapped = false;
  String? _formKeyId;

  ReviewQueueQuery get _query => ReviewQueueQuery(wordId: widget.wordId);

  @override
  void initState() {
    super.initState();
    _correctMode = widget.openCorrect;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final session = ref.read(reviewSessionProvider);
    final startId = widget.startId;

    if (session != null && (startId == null || session.ids.contains(startId))) {
      if (startId != null && session.currentId != startId) {
        final index = session.ids.indexOf(startId);
        if (index >= 0) {
          ref
              .read(reviewSessionProvider.notifier)
              .start(
                ids: session.ids,
                index: index,
                query: session.query,
                hasMore: session.hasMore,
                nextCursor: session.nextCursor,
              );
        }
      }
      return;
    }

    final queue = ref.read(reviewQueueProvider(_query)).value;
    if (queue != null && queue.items.isNotEmpty) {
      ref
          .read(reviewSessionProvider.notifier)
          .startFromQueue(queue, query: _query, startId: startId);
      return;
    }

    if (startId != null) {
      await ref
          .read(reviewSessionProvider.notifier)
          .startWithId(startId, query: _query);
      return;
    }

    // Tunggu antrean lalu mulai dari awal.
    try {
      final loaded = await ref.read(reviewQueueProvider(_query).future);
      if (!mounted) return;
      if (loaded.items.isEmpty) {
        _exitToQueue(refresh: false);
        return;
      }
      ref
          .read(reviewSessionProvider.notifier)
          .startFromQueue(loaded, query: _query);
    } catch (_) {
      if (!mounted) return;
      _exitToQueue(refresh: true);
    }
  }

  void _exitToQueue({required bool refresh}) {
    ref.read(reviewSessionProvider.notifier).clear();
    if (refresh) invalidateReviewQueue(ref);
    final path = widget.wordId != null
        ? '/review?wordId=${Uri.encodeComponent(widget.wordId!)}'
        : '/review';
    context.go(path);
  }

  Future<void> _afterDecision(String message, String contributionId) async {
    // Tetap busy sampai advance selesai supaya slot kartu menampilkan
    // skeleton (bukan ruang kosong setelah swipe) selama request + ganti item.
    setState(() => _correctMode = false);
    showFToast(context: context, title: Text(message));
    final hasNext = await ref
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision(contributionId);
    if (!mounted) return;
    if (!hasNext) {
      showFToast(context: context, title: const Text('Antrean selesai'));
      _exitToQueue(refresh: true);
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _afterSkip(String contributionId) async {
    setState(() => _busy = true);
    showFToast(context: context, title: const Text('Dilewati.'));
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewSkip,
      params: {'contribution_id': contributionId},
    );
    final hasNext = await ref
        .read(reviewSessionProvider.notifier)
        .skipCurrent();
    if (!mounted) return;
    if (!hasNext) {
      showFToast(context: context, title: const Text('Antrean selesai'));
      _exitToQueue(refresh: true);
      return;
    }
    setState(() => _busy = false);
  }

  /// `true` = kartu boleh tetap keluar / sesi advance; `false` = kembalikan kartu.
  Future<bool> _approve(ReviewDetail detail) async {
    if (_busy) return false;
    setState(() => _busy = true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .approve(detail.contribution.id);
    if (!mounted) return false;
    return result.match(
      (failure) {
        setState(() => _busy = false);
        return _onFailure(failure, detail.contribution.id);
      },
      (decision) {
        final merged = decision.mergedIntoWordId != null;
        AnalyticsService.instance.log(
          AnalyticsEvents.reviewApprove,
          params: {'contribution_id': detail.contribution.id},
        );
        _afterDecision(
          merged
              ? 'Disetujui. Makna digabung ke kata yang sudah tayang.'
              : 'Usulan disetujui.',
          detail.contribution.id,
        );
        return true;
      },
    );
  }

  /// `true` = ditolak / advance; `false` = batal alasan atau error yang bisa diulang.
  Future<bool> _reject(ReviewDetail detail) async {
    if (_busy) return false;
    final comment = await _askRejectReason();
    if (comment == null || !mounted) return false;
    setState(() => _busy = true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .reject(detail.contribution.id, comment: comment);
    if (!mounted) return false;
    return result.match(
      (failure) {
        setState(() => _busy = false);
        return _onFailure(failure, detail.contribution.id);
      },
      (_) {
        AnalyticsService.instance.log(
          AnalyticsEvents.reviewReject,
          params: {'contribution_id': detail.contribution.id},
        );
        _afterDecision('Usulan ditolak.', detail.contribution.id);
        return true;
      },
    );
  }

  Future<bool> _onSwiped(ReviewDetail detail, ReviewSwipeDirection direction) {
    return switch (direction) {
      ReviewSwipeDirection.approve => _approve(detail),
      ReviewSwipeDirection.reject => _reject(detail),
      ReviewSwipeDirection.skip => _skip(detail),
    };
  }

  Future<bool> _skip(ReviewDetail detail) async {
    if (_busy) return false;
    await _afterSkip(detail.contribution.id);
    return true;
  }

  Future<void> _rewindSkip() async {
    if (_busy) return;
    final ok = ref.read(reviewSessionProvider.notifier).rewindSkip();
    if (!ok || !mounted) return;
    setState(() => _correctMode = false);
    showFToast(
      context: context,
      title: const Text('Kartu sebelumnya dikembalikan.'),
    );
  }

  Future<String?> _askRejectReason() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => const _RejectReasonSheet(),
    );
  }

  /// `true` = sesi lanjut (forbidden / already decided); `false` = tetap di kartu.
  bool _onFailure(ReviewFailure failure, String contributionId) {
    if (failure.isForbidden) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewForbiddenPage(message: failure.message),
        ),
      );
      return true;
    }
    if (failure.isAlreadyDecided) {
      // Satu toast via _afterDecision - jangan dobel dengan toast terpisah.
      _afterDecision('Usulan ini sudah diproses.', contributionId);
      return true;
    }
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
    return false;
  }

  void _onCorrectSuccess(ReviewDetail detail, ReviewDecisionResult decision) {
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewCorrect,
      params: {'contribution_id': detail.contribution.id},
    );
    if (decision.status == 'pending') {
      // publish=false: tetap di item yang sama, kembali ke mode lihat.
      ref.invalidate(reviewDetailProvider(detail.contribution.id));
      setState(() => _correctMode = false);
      showFToast(
        context: context,
        title: const Text('Koreksi disimpan. Usulan tetap menunggu.'),
      );
      return;
    }
    setState(() => _busy = true);
    _afterDecision(
      'Koreksi disimpan dan usulan ditutup.',
      detail.contribution.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(reviewSessionProvider);
    final currentId = session?.currentId;

    if (session == null || currentId == null) {
      return FScaffold(
        header: FHeader.nested(
          title: const Text('Tinjau usulan'),
          prefixes: [
            FHeaderAction.back(onPress: () => _exitToQueue(refresh: false)),
          ],
        ),
        child: const Center(child: FCircularProgress()),
      );
    }

    final detailAsync = ref.watch(reviewDetailProvider(currentId));
    final failure = detailAsync.hasError ? detailAsync.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }

    final pending = detailAsync.asData?.value.contribution.isPending ?? false;
    final title = _correctMode
        ? 'Koreksi · ${session.position}/${session.total}'
        : _busy
        ? 'Menyimpan · ${session.position}/${session.total}'
        : 'Tinjau · ${session.position}/${session.total}';

    // Prefetch 1-2 kartu ke depan tetap di-watch supaya autoDispose tidak
    // membuang hasil sebelum advance (ganti kartu tanpa cold loading).
    final nextId = session.nextId;
    if (nextId != null) {
      ref.watch(reviewDetailProvider(nextId));
    }
    final afterNext = session.index + 2;
    if (afterNext >= 0 && afterNext < session.ids.length) {
      ref.watch(reviewDetailProvider(session.ids[afterNext]));
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              if (_correctMode) {
                setState(() => _correctMode = false);
                return;
              }
              _exitToQueue(refresh: false);
            },
          ),
        ],
      ),
      footer: pending && !_correctMode
          ? detailAsync.maybeWhen(
              data: (detail) => _ReviewActionBar(
                busy: _busy,
                canCorrect: detail.contribution.entityType != 'meaning',
                canRewind: session.canRewind,
                onApprove: () => _approve(detail),
                onCorrect: () => setState(() {
                  _formKeyId = detail.contribution.id;
                  _correctMode = true;
                }),
                onReject: () => _reject(detail),
                onSkip: () => _skip(detail),
                onRewind: _rewindSkip,
              ),
              orElse: () => null,
            )
          : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        // Saat submit: kartu sudah swipe keluar → skeleton mengisi slot
        // sampai advance ke item berikutnya (prefetch sering instan).
        child: _busy && !_correctMode
            ? const _ReviewCardPlaceholder(key: ValueKey('submitting'))
            : detailAsync.when(
                loading: () =>
                    const _ReviewCardPlaceholder(key: ValueKey('loading')),
                error: (error, _) => Center(
                  key: const ValueKey('error'),
                  child: Text(
                    error is ReviewFailure
                        ? error.message
                        : 'Gagal memuat detail',
                  ),
                ),
                data: (detail) {
                  if (_correctMode) {
                    return ReviewCorrectForm(
                      key: ValueKey(_formKeyId ?? detail.contribution.id),
                      detail: detail,
                      onCancel: () => setState(() => _correctMode = false),
                      onSuccess: (decision) =>
                          _onCorrectSuccess(detail, decision),
                      onFailure: (failure) =>
                          _onFailure(failure, detail.contribution.id),
                    );
                  }
                  final canSwipe = detail.contribution.isPending && !_busy;
                  return Padding(
                    key: ValueKey('card-${detail.contribution.id}'),
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: ReviewSwipeCard(
                      itemKey: detail.contribution.id,
                      enabled: canSwipe,
                      onSwiped: (direction) => _onSwiped(detail, direction),
                      child: _ReviewViewBody(detail: detail),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ReviewViewBody extends StatelessWidget {
  const _ReviewViewBody({required this.detail});

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final item = detail.contribution;
    final when = formatDateTimeIso(item.createdAt);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        Text(
          item.title,
          style: context.theme.typography.xl.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(
              icon: FLucideIcons.layers,
              label: reviewEntityLabel(item.entityType),
            ),
            _MetaChip(
              icon: FLucideIcons.user,
              label: item.contributorUsername ?? 'anonim',
            ),
            if (when.isNotEmpty)
              _MetaChip(icon: FLucideIcons.clock, label: when),
          ],
        ),
        if (detail.wordAlreadyVerified) ...[
          const Gap(14),
          FAlert(
            title: Text(
              detail.verifierUsername == null
                  ? 'Sudah terverifikasi. Menyetujui hanya menutup antrean.'
                  : 'Sudah terverifikasi oleh @${detail.verifierUsername}. Menyetujui hanya menutup antrean.',
            ),
          ),
        ],
        const Gap(18),
        ReviewEntityPreview(detail: detail),
        if (!item.isPending &&
            (detail.reviewComment?.trim().isNotEmpty ?? false)) ...[
          const Gap(16),
          _SectionNote(
            title: 'Catatan verifikator',
            body: detail.reviewComment!,
          ),
        ],
        if (item.isPending) ...[
          const Gap(16),
          Text(
            'Kanan hijau · kiri merah · atas lewati - atau pakai tombol di bawah.',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

/// Kerangka kartu saat detail berikutnya masih dimuat (skeletonizer, bukan spinner penuh).
class _ReviewCardPlaceholder extends StatelessWidget {
  const _ReviewCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
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

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colors.border),
        ),
        child: SkeletonizerConfig(
          data: SkeletonizerConfigData(effect: shimmer),
          child: IgnorePointer(
            child: Skeletonizer(
              enabled: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Text(
                    'Judul usulan contoh skeleton',
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MetaChip(
                        icon: FLucideIcons.layers,
                        label: 'Jenis entri',
                      ),
                      _MetaChip(icon: FLucideIcons.user, label: 'kontributor'),
                      _MetaChip(
                        icon: FLucideIcons.clock,
                        label: '21 Sep 2026 00:00',
                      ),
                    ],
                  ),
                  const Gap(18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.muted.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Judul bagian preview'),
                          Gap(10),
                          Text(
                            'Isi ringkas usulan agar kerangka kartu mendekati layout asli saat loading.',
                          ),
                          Gap(8),
                          Text('Baris meta tambahan untuk shimmer.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alasan penolakan umum. Chip mengirim teks label sebagai comment API.
const _rejectReasons = <String>[
  'Kurang akurat',
  'Ejaan atau penulisan salah',
  'Duplikat entri yang sudah ada',
  'Tidak relevan',
  'Media (gambar/audio) tidak sesuai',
  'Konten tidak pantas',
  'Informasi kurang lengkap',
  'Lainnya',
];

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();
  String? _selected;

  bool get _isOther => _selected == 'Lainnya';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;
    if (_isOther) {
      final text = _controller.text.trim();
      if (text.isEmpty) return;
      Navigator.pop(context, text);
      return;
    }
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final canSubmit =
        _selected != null && (!_isOther || _controller.text.trim().isNotEmpty);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Gap(16),
          Text(
            'Tolak usulan',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          Text(
            'Pilih alasan agar kontributor tahu apa yang perlu diperbaiki.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final reason in _rejectReasons)
                GestureDetector(
                  onTap: () => setState(() => _selected = reason),
                  child: FBadge(
                    variant: _selected == reason
                        ? FBadgeVariant.primary
                        : FBadgeVariant.secondary,
                    child: Text(reason),
                  ),
                ),
            ],
          ),
          if (_isOther) ...[
            const Gap(16),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _controller,
                onChange: (_) => setState(() {}),
              ),
              label: const Text('Alasan penolakan'),
              hint: 'Jelaskan alasan penolakan',
              maxLines: 4,
              autofocus: true,
            ),
          ],
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const Gap(10),
              Expanded(
                child: FButton(
                  variant: FButtonVariant.destructive,
                  onPress: canSubmit ? _submit : null,
                  child: const Text('Tolak'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colors.mutedForeground),
            const Gap(6),
            Text(
              label,
              style: theme.typography.xs.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(6),
            Text(body, style: theme.typography.sm),
          ],
        ),
      ),
    );
  }
}

/// Sticky action bar: Koreksi · [undo][skip][tolak][setuju].
class _ReviewActionBar extends StatelessWidget {
  const _ReviewActionBar({
    required this.busy,
    required this.canCorrect,
    required this.canRewind,
    required this.onApprove,
    required this.onCorrect,
    required this.onReject,
    required this.onSkip,
    required this.onRewind,
  });

  final bool busy;
  final bool canCorrect;
  final bool canRewind;
  final VoidCallback onApprove;
  final VoidCallback onCorrect;
  final VoidCallback onReject;
  final VoidCallback onSkip;
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
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              if (canCorrect) ...[
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: busy ? null : onCorrect,
                    prefix: const Icon(FLucideIcons.pencil),
                    child: const Text('Koreksi'),
                  ),
                ),
                const Gap(8),
              ] else
                const Spacer(),
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
                onPress: busy ? null : onSkip,
                child: _busyOr(const Icon(FLucideIcons.skipForward)),
              ),
              const Gap(12),
              // Tolak / setuju sejajar (sama pola ↓↑ di kontribusi).
              FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: busy ? 'Memproses…' : 'Tolak',
                onPress: busy ? null : onReject,
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
                semanticsLabel: busy ? 'Memproses…' : 'Setujui',
                onPress: busy ? null : onApprove,
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
      ),
    );
  }
}
