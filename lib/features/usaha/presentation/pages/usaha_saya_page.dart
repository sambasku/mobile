import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';
import '../usaha_labels.dart';
import '../widgets/usaha_ui.dart';

/// Usaha yang dikelola user + pengajuan perubahan (field-lock admin).
class UsahaSayaPage extends ConsumerWidget {
  const UsahaSayaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authed = ref.watch(authStatusProvider).value?.isAuth == true;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.usahaSayaTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.list.path),
          ),
        ],
      ),
      child: !authed
          ? const _LoginGate()
          : ref
                .watch(usahaMineControllerProvider)
                .when(
                  loading: () =>
                      const Center(child: FCircularProgress(size: .sm)),
                  error: (err, _) => _ErrorBody(
                    onRetry: () => ref.invalidate(usahaMineControllerProvider),
                    message: err is UsahaException
                        ? err.message
                        : l10n.usahaSayaLoadFailed,
                  ),
                  data: (mine) {
                    if (mine.items.isEmpty) return const _EmptyBody();
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(usahaMineControllerProvider.notifier)
                          .reload(),
                      child: TileGroupList<Usaha>(
                        items: mine.items,
                        hasMore: false,
                        onLoadMore: () async {},
                        tileBuilder: (ctx, usaha) => FTile(
                          prefix: const Icon(FLucideIcons.store),
                          title: Text(
                            usaha.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              usahaMetaLine(usaha),
                              if (usaha.pendingChanges > 0)
                                l10n.usahaPendingChanges(
                                  '${usaha.pendingChanges}',
                                ),
                            ].join('\n'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              usahaOperationalBadge(
                                    l10n,
                                    usaha.operationalStatus,
                                  ) ??
                                  const SizedBox.shrink(),
                              FButton(
                                variant: FButtonVariant.outline,
                                size: FButtonSizeVariant.sm,
                                onPress: () => _openActions(ctx, ref, usaha),
                                child: Text(l10n.usahaManage),
                              ),
                            ],
                          ),
                          onPress: () =>
                              context.push(UsahaRouter.detailPath(usaha.slug)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    Usaha usaha,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_ManageAction>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: Text(usaha.name),
              subtitle: Text(l10n.usahaManagePickChange),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.circleCheck, size: 18),
              title: Text(l10n.usahaManageOperational),
              onPress: () => Navigator.pop(ctx, _ManageAction.operational),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.listPlus, size: 18),
              title: Text(l10n.usahaManageItemAdd),
              onPress: () => Navigator.pop(ctx, _ManageAction.itemAdd),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.bookOpen, size: 18),
              title: Text(l10n.usahaManageCatalog),
              subtitle: Text(l10n.usahaManageCatalogBody),
              onPress: () => Navigator.pop(ctx, _ManageAction.catalog),
            ),
            if (usaha.publishStatus == UsahaPublishStatus.archived)
              FTile(
                prefix: const Icon(FLucideIcons.arrowUpFromLine, size: 18),
                title: Text(l10n.usahaManageRestore),
                onPress: () => Navigator.pop(ctx, _ManageAction.restore),
              )
            else
              FTile(
                prefix: const Icon(FLucideIcons.archive, size: 18),
                title: Text(l10n.usahaManageArchive),
                subtitle: Text(l10n.usahaManageArchiveBody),
                onPress: () => Navigator.pop(ctx, _ManageAction.archive),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _ManageAction.operational:
        await _submitOperational(context, ref, usaha);
      case _ManageAction.itemAdd:
        final item = await showModalBottomSheet<_ItemDraft>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (_) => _ItemSheet(title: l10n.usahaManageItemAdd),
        );
        if (item == null || !context.mounted) return;
        await _submit(context, ref, usaha, 'item_add', payload: item.toBody());
      case _ManageAction.catalog:
        await _openCatalog(context, ref, usaha);
      case _ManageAction.archive:
        await _submit(context, ref, usaha, 'archive');
      case _ManageAction.restore:
        await _submit(context, ref, usaha, 'restore');
    }
  }

  Future<void> _submitOperational(
    BuildContext context,
    WidgetRef ref,
    Usaha usaha,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showOptionPickerSheet<UsahaOperationalStatus>(
      context,
      title: l10n.usahaKindOperational,
      icon: FLucideIcons.circleCheck,
      items: [
        for (final status in UsahaOperationalStatus.values)
          OptionPickerItem(
            value: status,
            label: usahaOperationalLabel(l10n, status),
            selected: status == usaha.operationalStatus,
          ),
      ],
    );
    if (picked == null || !context.mounted) return;
    await _submit(
      context,
      ref,
      usaha,
      'operational',
      payload: {'operationalStatus': _operationalWire(picked)},
    );
  }

  Future<void> _openCatalog(
    BuildContext context,
    WidgetRef ref,
    Usaha usaha,
  ) async {
    final l10n = AppLocalizations.of(context);
    final detail = await ref.read(usahaBySlugProvider(usaha.slug).future);
    if (!context.mounted) return;
    final items = detail?.items ?? const <UsahaItem>[];
    final item = await showModalBottomSheet<UsahaItem>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: Text(l10n.usahaCatalog),
              subtitle: Text(l10n.usahaCatalogPick),
            ),
            if (items.isEmpty)
              FTile(title: Text(l10n.usahaCatalogEmpty))
            else
              for (final it in items)
                FTile(
                  title: Text(it.name),
                  subtitle: Text(usahaPriceLabel(l10n, it)),
                  suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                  onPress: () => Navigator.pop(ctx, it),
                ),
          ],
        ),
      ),
    );
    if (item == null || !context.mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(title: Text(item.name)),
            FTile(
              title: Text(l10n.usahaKindItemEdit),
              onPress: () => Navigator.pop(ctx, 'edit'),
            ),
            FTile(
              title: Text(l10n.usahaKindItemDelete),
              onPress: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    if (action == 'delete') {
      await _submit(context, ref, usaha, 'item_delete', itemId: item.id);
      return;
    }
    final draft = await showModalBottomSheet<_ItemDraft>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _ItemSheet(title: l10n.usahaKindItemEdit, initial: item),
    );
    if (draft == null || !context.mounted) return;
    await _submit(
      context,
      ref,
      usaha,
      'item_edit',
      itemId: item.id,
      payload: draft.toBody(),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    Usaha usaha,
    String kind, {
    String? itemId,
    Map<String, dynamic> payload = const {},
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(usahaContributionApiProvider)
          .submitManagerChange(
            kind: kind,
            usahaId: usaha.id,
            itemId: itemId,
            payload: payload,
          );
      if (!context.mounted) return;
      ref.invalidate(usahaMineControllerProvider);
      await showAppErrorSheet(
        context,
        title: l10n.usahaChangeSent,
        message: l10n.usahaChangeSentBody,
      );
    } on UsahaException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: l10n.usahaChangeFailed,
      );
    }
  }
}

enum _ManageAction { operational, itemAdd, catalog, archive, restore }

String _operationalWire(UsahaOperationalStatus status) => switch (status) {
  UsahaOperationalStatus.unknown => 'unknown',
  UsahaOperationalStatus.open => 'open',
  UsahaOperationalStatus.temporarilyClosed => 'temporarily_closed',
  UsahaOperationalStatus.permanentlyClosed => 'permanently_closed',
};

class _ItemDraft {
  const _ItemDraft({required this.name, this.description, this.priceText});

  final String name;
  final String? description;
  final String? priceText;

  Map<String, dynamic> toBody() => {
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (priceText != null && priceText!.isNotEmpty) 'priceText': priceText,
  };
}

/// Sheet form item katalog (tambah / ubah).
class _ItemSheet extends StatefulWidget {
  const _ItemSheet({required this.title, this.initial});

  final String title;
  final UsahaItem? initial;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );
  late final _price = TextEditingController(
    text: widget.initial?.priceText ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: _name),
                label: Text(l10n.usahaItemName),
                hint: l10n.usahaItemNameHint,
                textCapitalization: TextCapitalization.words,
              ),
              const Gap(10),
              FTextField(
                control: FTextFieldControl.managed(controller: _description),
                label: Text(l10n.usahaItemDescription),
                maxLines: 3,
              ),
              const Gap(10),
              FTextField(
                control: FTextFieldControl.managed(controller: _price),
                label: Text(l10n.usahaItemPrice),
                hint: l10n.usahaItemPriceHint,
              ),
              const Gap(16),
              FButton(
                onPress: () {
                  final name = _name.text.trim();
                  if (name.length < 2) {
                    showAppErrorSheet(
                      context,
                      title: l10n.usahaItemNameShortTitle,
                      message: l10n.usahaItemNameShort,
                    );
                    return;
                  }
                  Navigator.pop(
                    context,
                    _ItemDraft(
                      name: name,
                      description: _description.text.trim(),
                      priceText: _price.text.trim(),
                    ),
                  );
                },
                child: Text(l10n.usahaItemSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.store,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.usahaSayaLoginGate,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: Text(l10n.authLoginAction),
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
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const Gap(48),
        Center(
          child: Icon(
            FLucideIcons.store,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(10),
        Text(
          l10n.usahaSayaEmpty,
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          l10n.usahaSayaEmptyHint,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(16),
        Center(
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () => context.push(UsahaRouter.claims.path),
            child: Text(l10n.usahaSeeClaims),
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
        title: AppLocalizations.of(context).usahaLoadFailed,
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
