import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../../domain/entities/culinary_place.dart';
import '../../explore_router.dart';
import '../culinary_labels.dart';
import '../providers/cuisine_providers.dart';
import '../widgets/culinary_action_sheets.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Daftar tempat/penjual kuliner (`/api/v1/culinary/places`).
///
/// Aksi per tempat: klaim pengelolaan, usul status buka/tutup, lapor.
/// Semua butuh akun - guest dapat arahan masuk dulu.
class CulinaryPlacesPage extends ConsumerStatefulWidget {
  const CulinaryPlacesPage({super.key});

  @override
  ConsumerState<CulinaryPlacesPage> createState() => _CulinaryPlacesPageState();
}

class _CulinaryPlacesPageState extends ConsumerState<CulinaryPlacesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final placesAsync = ref.watch(culinaryPlacesProvider(q: _query));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.culinaryPlacesTitle),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () =>
                context.push(ExploreRouter.cuisinePlaceContribute.path),
            semanticsLabel: l10n.culinaryPlacesContribute,
          ),
        ],
      ),
      child: placesAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) =>
            _ErrorBody(onRetry: () => ref.invalidate(culinaryPlacesProvider)),
        data: (page) {
          if (page == null) {
            return _ErrorBody(
              onRetry: () => ref.invalidate(culinaryPlacesProvider),
            );
          }
          final items = page.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (value) =>
                      setState(() => _query = value.text.trim()),
                ),
                hint: l10n.culinaryPlacesSearchHint,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              const Gap(12),
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.culinaryPlacesEmpty,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _PlaceTile(place: items[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({required this.place});

  final CulinaryPlace place;

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      await showAppErrorSheet(
        context,
        title: l10n.culinaryLoginTitle,
        message:
            l10n.culinaryPlacesLoginBody,
      );
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: Text(l10n.culinaryClaimPlace),
              subtitle: Text(l10n.culinaryClaimPlaceBody),
              onPress: () => Navigator.pop(ctx, 'claim'),
            ),
            FTile(
              title: Text(l10n.culinarySuggestEdit),
              subtitle: Text(l10n.culinarySuggestEditPlaceBody),
              onPress: () => Navigator.pop(ctx, 'edit'),
            ),
            FTile(
              title: Text(l10n.culinarySuggestOperational),
              onPress: () => Navigator.pop(ctx, 'operational'),
            ),
            FTile(
              title: Text(l10n.usahaReportTitle),
              onPress: () => Navigator.pop(ctx, 'report'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case 'claim':
        await _claim(context, ref);
      case 'edit':
        await showCulinaryEditSheet(
          context,
          ref,
          target: CulinaryEditTarget.place(
            id: place.id,
            name: place.name,
            description: place.description ?? '',
            addressText: place.addressText,
          ),
        );
      case 'operational':
        await _operational(context, ref);
      case 'report':
        await _report(context, ref);
    }
  }

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final evidence = await _askText(
      context,
      title: l10n.culinaryClaimManageTitle,
      hint: l10n.culinaryClaimEvidenceHint,
    );
    if (evidence == null) return;
    if (evidence.length < 5) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryEvidenceShortTitle,
        message: l10n.culinaryEvidenceShortBody,
      );
      return;
    }
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .claimPlace(place.slug, contactEvidence: evidence);
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryClaimSent,
        message: l10n.culinaryClaimPlaceSentBody,
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryClaimFailed,
        message: e.message,
      );
    }
  }

  Future<void> _operational(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    const statuses = [
      'operating',
      'temporarily_closed',
      'permanently_closed',
      'unknown',
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            for (final status in statuses)
              FTile(
                title: Text(culinaryOperationalLabel(l10n, status)),
                suffix: status == place.operationalStatus
                    ? const Icon(FLucideIcons.check, size: 18)
                    : null,
                onPress: () => Navigator.pop(ctx, status),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .submitChange(
            kind: 'place_operational',
            placeId: place.id,
            payload: {'operationalStatus': picked},
            fields: const ['operationalStatus'],
          );
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryOperationalSent,
        message: l10n.culinaryOperationalSentBody,
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryProposalFailed,
        message: e.message,
      );
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          label: Text(l10n.culinaryReportReasonTitle),
          children: [
          for (final code in culinaryReportReasons)
            FTile(
              title: Text(culinaryReportReasonLabel(l10n, code)),
              onPress: () => Navigator.pop(ctx, code),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .reportPlace(place.slug, reasonCode: picked);
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.usahaReportSent,
        message: l10n.culinaryPlaceReportSentBody,
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.culinaryReportFailed,
        message: e.message,
      );
    }
  }

  Future<String?> _askText(
    BuildContext context, {
    required String title,
    required String hint,
  }) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: ctx.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  l10n.culinaryClaimEvidenceBody,
                  style: ctx.theme.typography.body.sm.copyWith(
                    color: ctx.theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FTextField.multiline(
                  control: FTextFieldControl.managed(controller: controller),
                  hint: hint,
                  maxLines: 4,
                ),
                const Gap(16),
                FButton(
                  onPress: () => Navigator.pop(ctx, controller.text.trim()),
                  child: Text(l10n.culinaryClaimSubmit),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.pop(ctx),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final place = this.place;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _actions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 64,
                  child: place.coverUrl == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            FLucideIcons.store,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : Image.network(
                          place.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colors.muted,
                            child: Icon(
                              FLucideIcons.store,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      culinaryOperationalLabel(l10n, place.operationalStatus),
                      style: theme.typography.body.xs.copyWith(
                        color: place.operationalStatus == 'operating'
                            ? theme.colors.primary
                            : theme.colors.mutedForeground,
                      ),
                    ),
                    if (place.addressText != null || place.locationHint != null)
                      Text(
                        place.addressText ?? place.locationHint!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                FLucideIcons.chevronRight,
                size: 18,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FAlert(
              title: Text(l10n.culinaryLoadFailed),
              subtitle: Text(l10n.culinaryConnectionFailed),
            ),
            const Gap(16),
            FButton(onPress: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
