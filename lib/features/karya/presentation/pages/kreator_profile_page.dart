import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/external_link.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/karya_api.dart';
import '../../domain/karya.dart';
import '../../karya_router.dart';
import '../karya_providers.dart';

class KreatorProfilePage extends ConsumerWidget {
  const KreatorProfilePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(kreatorBySlugProvider(slug));
    return async.when(
      loading: () => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.kreatorTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: const Center(child: FCircularProgress()),
      ),
      error: (_, _) => FScaffold(
        header: FHeader.nested(
          title: Text(l10n.kreatorTitle),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(child: Text(l10n.kreatorLoadFailed)),
      ),
      data: (profile) {
        if (profile == null) {
          return FScaffold(
            header: FHeader.nested(
              title: Text(l10n.kreatorTitle),
              prefixes: [FHeaderAction.back(onPress: () => context.pop())],
            ),
            child: Center(child: Text(l10n.kreatorNotFound)),
          );
        }
        return _KreatorProfileBody(profile: profile);
      },
    );
  }
}

class _KreatorProfileBody extends ConsumerStatefulWidget {
  const _KreatorProfileBody({required this.profile});

  final KreatorProfile profile;

  @override
  ConsumerState<_KreatorProfileBody> createState() =>
      _KreatorProfileBodyState();
}

class _KreatorProfileBodyState extends ConsumerState<_KreatorProfileBody> {
  var _claimBusy = false;

  KreatorProfile get profile => widget.profile;

  Future<void> _claim() async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    final noteCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.kreatorClaimTitle,
                  style: sheetContext.theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  l10n.kreatorClaimSubtitle,
                  style: sheetContext.theme.typography.body.sm.copyWith(
                    color: sheetContext.theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FTextField(
                  control: FTextFieldControl.managed(controller: noteCtrl),
                  label: Text(l10n.kreatorClaimProof),
                  description: Text(l10n.kreatorClaimProofHint),
                  maxLines: 4,
                  minLines: 3,
                ),
                const Gap(16),
                FButton(
                  onPress: () => Navigator.pop(sheetContext, true),
                  child: Text(l10n.kreatorClaimSubmit),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.pop(sheetContext, false),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final note = noteCtrl.text.trim();
    noteCtrl.dispose();
    if (ok != true || !mounted) return;
    if (note.length < 8) {
      await showAppErrorSheet(context, message: l10n.kreatorClaimProofShort);
      return;
    }
    setState(() => _claimBusy = true);
    try {
      await ref.read(karyaApiProvider).claimKreator(
            profile.slug,
            proofNote: note,
          );
      if (!mounted) return;
      showFToast(context: context, title: Text(l10n.kreatorClaimSuccess));
    } catch (error) {
      if (!mounted) return;
      final message = karyaErrorMessage(error);
      await showAppErrorSheet(
        context,
        message: message.isEmpty ? l10n.kreatorLoadFailed : message,
      );
    } finally {
      if (mounted) setState(() => _claimBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final bio = (profile.bio ?? '').trim();
    final origin = (profile.originRegion ?? '').trim();
    final kindLabel = profile.kind == 'group'
        ? l10n.kreatorKindGroup
        : l10n.kreatorKindPerson;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(profile.displayName),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: () => context.push(
              KaryaRouter.contributePath(
                creditName: profile.displayName,
                kind: profile.karyas.isNotEmpty
                    ? profile.karyas.first.kind
                    : null,
              ),
            ),
            child: Text(l10n.kreatorProposeKarya),
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
              if (origin.isNotEmpty)
                FBadge(
                  variant: FBadgeVariant.outline,
                  child: Text(origin),
                ),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const Gap(12),
            Text(
              bio,
              style: theme.typography.body.md.copyWith(height: 1.45),
            ),
          ] else ...[
            const Gap(12),
            Text(
              l10n.kreatorBioEmpty,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          if (profile.links.isNotEmpty) ...[
            const Gap(18),
            Text(
              l10n.kreatorLinks,
              style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            FTileGroup(
              children: [
                for (final link in profile.links)
                  FTile(
                    title: Text(
                      link.label.isEmpty ? l10n.karyaAccessKindOfficial : link.label,
                    ),
                    suffix: Icon(
                      FLucideIcons.externalLink,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: () => launchExternalUrl(Uri.parse(link.url)),
                  ),
              ],
            ),
          ],
          const Gap(18),
          Text(
            l10n.kreatorKaryaSection,
            style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (profile.karyas.isEmpty)
            Text(
              l10n.kreatorKaryaEmpty,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            FTileGroup(
              children: [
                for (final karya in profile.karyas)
                  FTile(
                    title: Text(karya.title),
                    subtitle: Text(
                      [
                        karya.kind == 'music'
                            ? l10n.karyaKindMusic
                            : l10n.karyaKindFilm,
                        if (karya.year != null)
                          l10n.karyaYearLabel(karya.year!),
                        if (karya.role.isNotEmpty)
                          _roleLabel(l10n, karya.kind, karya.role),
                      ].join(' · '),
                    ),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: () =>
                        context.push(KaryaRouter.detailPath(karya.slug)),
                  ),
              ],
            ),
          const Gap(12),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.badgeCheck,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.kreatorClaimAction),
                subtitle: Text(l10n.kreatorClaimActionHint),
                suffix: _claimBusy
                    ? const FCircularProgress(size: .sm)
                    : Icon(
                        FLucideIcons.chevronRight,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                onPress: _claimBusy ? null : _claim,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, String kind, String role) {
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
