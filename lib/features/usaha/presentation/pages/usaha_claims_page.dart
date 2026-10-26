import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';

/// Klaim pengelolaan milik user + statusnya.
class UsahaClaimsPage extends ConsumerWidget {
  const UsahaClaimsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Klaim saya'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go(UsahaRouter.list.path),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(usahaClaimsControllerProvider)
                .when(
                  loading: () => const Center(child: FCircularProgress(size: .sm)),
                  error: (err, _) => _ErrorBody(
                    onRetry: () => ref.invalidate(usahaClaimsControllerProvider),
                    message: err is UsahaException
                        ? err.message
                        : 'Gagal memuat klaim. Periksa koneksi lalu coba lagi.',
                  ),
                  data: (items) {
                    if (items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(usahaClaimsControllerProvider.future),
                      child: TileGroupList<UsahaClaim>(
                        items: items,
                        hasMore: false,
                        onLoadMore: () async {},
                        tileBuilder: (ctx, item) => _ClaimRow(
                          item: item,
                          onCancel: () => _confirmCancel(ctx, ref, item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    UsahaClaim item,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: const Text('Batalkan klaim?'),
              subtitle: const Text('Kamu bisa ajukan klaim baru kapan saja.'),
              suffix: FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.pop(ctx, true),
                child: const Text('Batalkan'),
              ),
            ),
            FTile(
              title: const Text('Biarkan dulu'),
              suffix: FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.pop(ctx, false),
                child: const Text('Tidak jadi'),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(usahaClaimsControllerProvider.notifier).cancel(item.id);
    } on UsahaException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(context, message: e.message, title: 'Gagal membatalkan');
    }
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({required this.item, required this.onCancel});

  final UsahaClaim item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pending = item.status == UsahaClaimStatus.pending;
    final name = item.usahaName ?? 'Usaha';
    final note = item.status == UsahaClaimStatus.rejected ? item.rejectReason : null;

    return FTile(
      prefix: Icon(
        FLucideIcons.keyRound,
        color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: pending ? theme.colors.foreground : theme.colors.mutedForeground,
          fontWeight: pending ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        note == null
            ? 'Diajukan ${formatDateShort(item.createdAt)}'
            : 'Diajukan ${formatDateShort(item.createdAt)}\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _variant(item.status),
            child: Text(_label(item.status)),
          ),
          if (pending) ...[
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

  static FBadgeVariant _variant(UsahaClaimStatus status) => switch (status) {
    UsahaClaimStatus.approved => FBadgeVariant.primary,
    UsahaClaimStatus.rejected => FBadgeVariant.destructive,
    UsahaClaimStatus.cancelled => FBadgeVariant.outline,
    UsahaClaimStatus.pending => FBadgeVariant.secondary,
  };

  static String _label(UsahaClaimStatus status) => switch (status) {
    UsahaClaimStatus.approved => 'Disetujui',
    UsahaClaimStatus.rejected => 'Ditolak',
    UsahaClaimStatus.cancelled => 'Dibatalkan',
    UsahaClaimStatus.pending => 'Menunggu',
  };
}

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
            Icon(FLucideIcons.keyRound, size: 40, color: theme.colors.mutedForeground),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat klaim kamu',
              style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
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
            FLucideIcons.shieldCheck,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          'Belum ada klaim',
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          'Buka detail usaha lalu pilih "Ini usaha saya" untuk mengajukan klaim.',
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
  final String message;

  @override
  State<_ErrorBody> createState() => _ErrorBodyState();
}

class _ErrorBodyState extends State<_ErrorBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: widget.message,
        title: 'Gagal memuat klaim',
        onRetry: widget.onRetry,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 240)],
      ),
    );
  }
}
