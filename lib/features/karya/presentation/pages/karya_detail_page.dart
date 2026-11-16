import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/external_link.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/karya.dart';
import '../../karya_router.dart';
import '../karya_providers.dart';

class KaryaDetailPage extends ConsumerWidget {
  const KaryaDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(karyaBySlugProvider(slug));
    return async.when(
      loading: () => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.karyaTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: const Center(child: FCircularProgress()),
      ),
      error: (_, _) => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.karyaTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(child: Text(l10n.karyaLoadFailed)),
      ),
      data: (item) {
        if (item == null) {
          return FScaffold(
            header: FHeader.nested(
              title: Text(l10n.karyaTitle),
              prefixes: [FHeaderAction.back(onPress: () => context.pop())],
            ),
            child: Center(child: Text(l10n.karyaNotFound)),
          );
        }
        return _KaryaDetailBody(item: item);
      },
    );
  }
}

class _KaryaDetailBody extends ConsumerWidget {
  const _KaryaDetailBody({required this.item});

  final KaryaEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kindLabel =
        item.isMusic ? l10n.karyaKindMusic : l10n.karyaKindFilm;
    final primary = item.primaryAccess;
    final secondaries = item.secondaryAccess;
    final description = (item.description ?? '').trim();

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(item.title),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: primary == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: () =>
                      launchExternalUrl(Uri.parse(primary.url)),
                  child: Text(primary.label),
                ),
              ),
            ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text(kindLabel),
              ),
              FBadge(
                variant: FBadgeVariant.outline,
                child: Text(l10n.karyaYearLabel(item.year)),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const Gap(12),
            Text(
              description,
              style: theme.typography.body.md.copyWith(height: 1.45),
            ),
          ],
          const Gap(18),
          Text(
            l10n.karyaSambasSection,
            style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (item.sambasConnections.isEmpty)
            Text(
              l10n.karyaSambasEmpty,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            FTileGroup(
              children: [
                for (final row in item.sambasConnections)
                  FTile(
                    title: Text(_sambasTypeLabel(l10n, row.type)),
                    subtitle: Text(row.note),
                  ),
              ],
            ),
          const Gap(18),
          Text(
            l10n.karyaCredits,
            style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          FTileGroup(
            children: [
              for (final credit in item.credits)
                FTile(
                  title: Text(credit.nameText),
                  subtitle: Text(_creditRoleLabel(l10n, item.kind, credit.role)),
                ),
            ],
          ),
          const Gap(18),
          Text(
            l10n.karyaAccess,
            style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (item.accessLinks.isEmpty)
            Text(
              l10n.karyaAccessEmpty,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else if (secondaries.isNotEmpty)
            FTileGroup(
              children: [
                for (final link in secondaries)
                  FTile(
                    title: Text(link.label),
                    subtitle: Text(_accessKindLabel(l10n, link.kind)),
                    suffix: Icon(
                      FLucideIcons.externalLink,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: () =>
                        launchExternalUrl(Uri.parse(link.url)),
                  ),
              ],
            ),
          const Gap(8),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.link,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.karyaProposeAccessLink),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => _openContribute(context, ref),
              ),
            ],
          ),
          if (item.excerpts.isNotEmpty) ...[
            const Gap(18),
            Text(
              l10n.karyaExcerptSection,
              style:
                  theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            FTileGroup(
              children: [
                for (final excerpt in item.excerpts)
                  FTile(
                    title: Text(excerpt.text, maxLines: 4),
                    subtitle: Text(excerpt.kind),
                  ),
              ],
            ),
          ],
          const Gap(12),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.pencil,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.karyaProposeEdit),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => _openContribute(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openContribute(BuildContext context, WidgetRef ref) {
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    context.push(
      KaryaRouter.contributePath(
        karyaId: item.id,
        slug: item.slug,
      ),
    );
  }

  String _sambasTypeLabel(AppLocalizations l10n, String type) =>
      switch (type) {
        'creator_origin' => l10n.karyaSambasTypeCreatorOrigin,
        'language' => l10n.karyaSambasTypeLanguage,
        'location' => l10n.karyaSambasTypeLocation,
        'theme' => l10n.karyaSambasTypeTheme,
        'other' => l10n.karyaSambasTypeOther,
        _ => type,
      };

  String _accessKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
        'listen' => l10n.karyaAccessKindListen,
        'watch' => l10n.karyaAccessKindWatch,
        'buy' => l10n.karyaAccessKindBuy,
        'read' => l10n.karyaAccessKindRead,
        'stream' => l10n.karyaAccessKindStream,
        'official' => l10n.karyaAccessKindOfficial,
        'other' => l10n.karyaAccessKindOther,
        _ => kind,
      };

  String _creditRoleLabel(AppLocalizations l10n, String kind, String role) {
    if (kind == 'music') {
      return switch (role) {
        'vocal' => l10n.karyaCreditRoleVocal,
        'feat' => l10n.karyaCreditRoleFeat,
        'songwriter' => l10n.karyaCreditRoleSongwriter,
        'composer' => l10n.karyaCreditRoleComposer,
        'producer' => l10n.karyaCreditRoleProducer,
        'arranger' => l10n.karyaCreditRoleArranger,
        'band_member' => l10n.karyaCreditRoleBandMember,
        'other' => l10n.karyaCreditRoleOther,
        _ => role,
      };
    }
    return switch (role) {
      'director' => l10n.karyaCreditRoleDirector,
      'cast' => l10n.karyaCreditRoleCast,
      'writer' => l10n.karyaCreditRoleWriter,
      'producer' => l10n.karyaCreditRoleProducer,
      'cinematographer' => l10n.karyaCreditRoleCinematographer,
      'composer' => l10n.karyaCreditRoleComposer,
      'other' => l10n.karyaCreditRoleOther,
      _ => role,
    };
  }
}