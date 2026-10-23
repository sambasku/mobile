import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/place_contribution_api.dart';

/// Daftar usulan wisata milik akun yang sedang masuk.
class PlaceProposalsPage extends ConsumerStatefulWidget {
  const PlaceProposalsPage({super.key});

  @override
  ConsumerState<PlaceProposalsPage> createState() => _PlaceProposalsPageState();
}

class _PlaceProposalsPageState extends ConsumerState<PlaceProposalsPage> {
  List<PlaceProposal>? _items;
  Object? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  PlaceContributionApi get _api => PlaceContributionApi(ref.read(dioProvider));

  Future<void> _load() async {
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      if (mounted) {
        setState(() {
          _loading = false;
          _items = const [];
        });
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.mine();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _cancel(PlaceProposal item) async {
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
    if (ok != true || !mounted) return;
    try {
      await _api.cancel(item.id);
      await _load();
    } on PlaceContributionException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulan wisata'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: !authed
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FLucideIcons.mapPin,
                      size: 40,
                      color: context.theme.colors.mutedForeground,
                    ),
                    const Gap(10),
                    Text(
                      'Masuk dulu untuk melihat usulan kamu',
                      style: context.theme.typography.body.md.copyWith(
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
            )
          : _loading
          ? const Center(child: FCircularProgress())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FLucideIcons.circleAlert,
                      size: 40,
                      color: context.theme.colors.mutedForeground,
                    ),
                    const Gap(10),
                    Text(
                      'Gagal memuat usulan',
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: _load,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _items == null || _items!.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const Gap(48),
                        Center(
                          child: Icon(
                            FLucideIcons.mapPin,
                            size: 40,
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          'Belum ada usulan',
                          textAlign: TextAlign.center,
                          style: context.theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Status usulan yang sudah direview akan muncul di sini.',
                          textAlign: TextAlign.center,
                          style: context.theme.typography.body.sm.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    )
                  : TileGroupList<PlaceProposal>(
                      items: _items!,
                      hasMore: false,
                      onLoadMore: () async {},
                      tileBuilder: (context, item) => _ProposalRow(
                        item: item,
                        onCancel: () => _cancel(item),
                      ),
                    ),
            ),
    );
  }
}

String _statusLabel(String status) => switch (status) {
  'approved' => 'Disetujui',
  'rejected' => 'Ditolak',
  _ => 'Menunggu',
};

FBadgeVariant _statusVariant(String status) => switch (status) {
  'approved' => FBadgeVariant.primary,
  'rejected' => FBadgeVariant.destructive,
  _ => FBadgeVariant.outline,
};

String _kindLabel(PlaceProposal item) =>
    item.placeId == null ? 'Tempat baru' : 'Suntingan';

String _typeLabel(String? type) => switch (type) {
  'sejarah' => 'Sejarah',
  'alam' => 'Alam',
  'budaya' => 'Budaya',
  'pantai' => 'Pantai',
  'belanja' => 'Belanja',
  null || '' => '',
  _ => type,
};

String _date(int seconds) {
  if (seconds <= 0) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({required this.item, required this.onCancel});

  final PlaceProposal item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pending = item.status == 'pending';
    final type = _typeLabel(item.type);
    final meta = [
      _kindLabel(item),
      if (type.isNotEmpty) type,
      _date(item.createdAt),
    ].where((part) => part.isNotEmpty).join(' · ');
    return FTile(
      prefix: Icon(
        FLucideIcons.mapPin,
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
        item.rejectReason == null
            ? meta
            : '$meta\nAlasan: ${item.rejectReason}',
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _statusVariant(item.status),
            child: Text(_statusLabel(item.status)),
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
}
