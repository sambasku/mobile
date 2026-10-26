import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/event_contribution.dart';
import '../providers/event_proposals_provider.dart';

/// Status usulan acara milik akun yang sedang masuk.
class EventProposalsPage extends ConsumerWidget {
  const EventProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulan acara'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(eventProposalsControllerProvider)
                .when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .sm)),
                  // Error tampil sebagai sheet (bisa "Coba lagi" langsung);
                  // di belakangnya tetap ada body + pull-to-refresh.
                  error: (err, _) => _ErrorBody(
                    onRetry: () =>
                        ref.invalidate(eventProposalsControllerProvider),
                    message: err is EventContributionException
                        ? err.message
                        : 'Gagal memuat usulan. Periksa koneksi lalu coba lagi.',
                  ),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(eventProposalsControllerProvider.future),
                      child: TileGroupList<EventContribution>(
                        items: items,
                        hasMore: false,
                        onLoadMore: () async {},
                        tileBuilder: (context, item) => _ProposalRow(
                          item: item,
                          onCancel: () => _cancel(context, ref, item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    EventContribution item,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.viewInsetsOf(ctx),
        child: SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: const Text('Batalkan usulan?'),
                subtitle: Text(item.name),
              ),
              FTile(
                title: const Text(
                  'Usulan yang dibatalkan tidak dikirim ke peninjau.',
                ),
              ),
              FTile(
                title: const Text('Batalkan'),
                onPress: () => Navigator.pop(ctx, true),
              ),
              FTile(
                title: const Text('Tutup'),
                onPress: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(eventProposalsControllerProvider.notifier).cancel(item.id);
    } on EventContributionException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(context, message: e.message);
    }
  }
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({required this.item, required this.onCancel});

  final EventContribution item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pending = item.isPending;
    final schedule = item.startsAt == null ? '' : formatDateTime(item.startsAt);
    final meta = [
      if (schedule.isNotEmpty) schedule,
      if (item.locationText != null && item.locationText!.isNotEmpty)
        item.locationText!,
    ].join(' · ');
    final note = switch (item.status) {
      EventContributionStatus.rejected => item.rejectReason,
      EventContributionStatus.needsRevision => item.revisionNote,
      _ => null,
    };

    return FTile(
      prefix: Icon(
        FLucideIcons.calendarDays,
        color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      title: Text(
        item.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: pending
              ? theme.colors.foreground
              : theme.colors.mutedForeground,
          fontWeight: pending ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        note == null ? meta : '$meta\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _statusVariant(item.status),
            child: Text(_statusLabel(item.status)),
          ),
          if (item.canCancel) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: onCancel,
              child: const Text('Batalkan'),
            ),
          ],
        ],
      ),
    );
  }
}

String _statusLabel(EventContributionStatus status) => switch (status) {
  EventContributionStatus.approved => 'Disetujui',
  EventContributionStatus.rejected => 'Ditolak',
  EventContributionStatus.needsRevision => 'Perlu revisi',
  EventContributionStatus.pending => 'Menunggu',
};

FBadgeVariant _statusVariant(EventContributionStatus status) =>
    switch (status) {
      EventContributionStatus.approved => FBadgeVariant.primary,
      EventContributionStatus.rejected => FBadgeVariant.destructive,
      EventContributionStatus.needsRevision => FBadgeVariant.secondary,
      EventContributionStatus.pending => FBadgeVariant.outline,
    };

class _LoginGate extends StatelessWidget {
  const _LoginGate();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.calendarDays,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat usulan kamu',
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const Gap(48),
        Center(
          child: Icon(
            FLucideIcons.calendarDays,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          'Belum ada usulan',
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          'Status usulan yang sudah direview akan muncul di sini.',
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatefulWidget {
  const _ErrorBody({required this.onRetry, required this.message});

  final VoidCallback onRetry;

  /// Pesan yang ditampilkan di bottom sheet saat error muncul.
  final String message;

  @override
  State<_ErrorBody> createState() => _ErrorBodyState();
}

class _ErrorBodyState extends State<_ErrorBody> {
  @override
  void initState() {
    super.initState();
    // Sheet error dibuka sekali saat state error pertama kali tampil.
    // isScrollControlled + useSafeArea sudah diatur helper.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: widget.message,
        title: 'Gagal memuat usulan',
        onRetry: widget.onRetry,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pull-to-refresh tetap tersedia walau sheet sudah ditutup.
    return RefreshIndicator(
      onRefresh: () async => widget.onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 240)],
      ),
    );
  }
}
