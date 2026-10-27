import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
                title: Text(l10n.placeProposalsCancelTitle),
                subtitle: Text(item.name),
              ),
              FTile(
                title: Text(l10n.placeProposalsCancelBody),
              ),
              FTile(
                title: Text(l10n.placeProposalsCancelAction),
                onPress: () => Navigator.pop(ctx, true),
              ),
              FTile(
                title: Text(l10n.commonClose),
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
    final l10n = AppLocalizations.of(context);
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.placeProposalsTitle),
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
                      l10n.placeProposalsLoginGate,
                      style: context.theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => context.push('/login'),
                      child: Text(l10n.commonLoginRequiredShort),
                    ),
                  ],
                ),
              ),
            )
          : _loading
          ? const Center(child: FCircularProgress())
        : _error != null
            ? _ErrorSheetOnce(
                message: _error is PlaceContributionException
                    ? (_error! as PlaceContributionException).message
                    : l10n.placeProposalsLoadFailedBody,
                onRetry: _load,
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
                          l10n.placeProposalsEmptyTitle,
                          textAlign: TextAlign.center,
                          style: context.theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          l10n.placeProposalsEmptyBody,
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

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'approved' => l10n.usahaStatusApproved,
  'rejected' => l10n.usahaStatusRejected,
  _ => l10n.usahaStatusPending,
};

FBadgeVariant _statusVariant(String status) => switch (status) {
  'approved' => FBadgeVariant.primary,
  'rejected' => FBadgeVariant.destructive,
  _ => FBadgeVariant.outline,
};

String _kindLabel(AppLocalizations l10n, PlaceProposal item) =>
    item.placeId == null
    ? l10n.placeProposalsKindNew
    : l10n.placeProposalsKindEdit;

String _typeLabel(AppLocalizations l10n, String? type) => switch (type) {
  'sejarah' => l10n.placeTypeSejarah,
  'alam' => l10n.placeTypeAlam,
  'budaya' => l10n.placeTypeBudaya,
  'pantai' => l10n.placeTypePantai,
  'belanja' => l10n.placeTypeBelanja,
  null || '' => '',
  _ => type,
};

String _date(int seconds) {
  if (seconds <= 0) return '';
  final d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  return formatDateYmd(
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
  );
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({required this.item, required this.onCancel});

  final PlaceProposal item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final pending = item.status == 'pending';
    final type = _typeLabel(l10n, item.type);
    final meta = [
      _kindLabel(l10n, item),
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
            : '$meta\n${l10n.placeProposalsRejectReason(item.rejectReason!)}',
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FBadge(
            variant: _statusVariant(item.status),
            child: Text(_statusLabel(l10n, item.status)),
          ),
          if (pending) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: onCancel,
              child: Text(l10n.placeProposalsCancelAction),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error muat data: bottom sheet (sekali per error) + pull-to-refresh di
/// belakangnya supaya tetap bisa mencoba lagi setelah sheet ditutup.
class _ErrorSheetOnce extends StatefulWidget {
  const _ErrorSheetOnce({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  State<_ErrorSheetOnce> createState() => _ErrorSheetOnceState();
}

class _ErrorSheetOnceState extends State<_ErrorSheetOnce> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: widget.message,
        title: AppLocalizations.of(context).placeProposalsLoadFailedTitle,
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
