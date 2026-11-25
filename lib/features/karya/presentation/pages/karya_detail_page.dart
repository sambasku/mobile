import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/external_link.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/entity_comments/entity_comment.dart';
import '../../../../shared/entity_comments/entity_comment_providers.dart';
import '../../../../shared/entity_comments/entity_comments_section.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../encyclopedia/encyclopedia_router.dart';
import '../../../event/event_router.dart';
import '../../../explore/explore_router.dart';
import '../../../usaha/usaha_router.dart';
import '../../../jinye/presentation/widgets/jinye_word_picker_sheet.dart';
import '../../data/karya_api.dart';
import '../../domain/karya.dart';
import '../../karya_router.dart';
import '../karya_providers.dart';
import '../widgets/karya_film_stage.dart';
import '../widgets/karya_music_stage.dart';

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
        return _KaryaDetailBody(item: item, slug: slug);
      },
    );
  }
}

class _KaryaDetailBody extends ConsumerStatefulWidget {
  const _KaryaDetailBody({required this.item, required this.slug});

  final KaryaEntry item;
  final String slug;

  @override
  ConsumerState<_KaryaDetailBody> createState() => _KaryaDetailBodyState();
}

class _KaryaDetailBodyState extends ConsumerState<_KaryaDetailBody> {
  String? _linkingExcerptId;

  KaryaEntry get item => widget.item;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) return;
      unawaited(_recordView());
    });
  }

  Future<void> _recordView() async {
    try {
      await ref.read(karyaApiProvider).recordView(widget.slug);
    } catch (_) {
      // best-effort
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kindLabel =
        item.isMusic ? l10n.karyaKindMusic : l10n.karyaKindFilm;
    final primary = item.primaryAccess;
    final watch = item.watchAccess;
    final trailer = item.trailerAccess;
    final secondaries = item.isFilm
        ? item.accessLinksBeyondStageCtas
        : item.secondaryAccess;
    final description = (item.description ?? '').trim();

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(item.title),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      // CTA dengar/tonton di panggung. Footer = entrance komentar (pola acara).
      footer: EntityCommentEntryBar(
        target: EntityCommentTarget.karya,
        entityId: item.id,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(karyaBySlugProvider(widget.slug));
          ref.invalidate(
            entityCommentListControllerProvider(
              EntityCommentListKey(EntityCommentTarget.karya, item.id),
            ),
          );
          await ref.read(karyaBySlugProvider(widget.slug).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
          if (item.isMusic) ...[
            KaryaMusicStage(
              item: item,
              listenLabel: primary?.label,
              onListen: primary == null
                  ? null
                  : () => launchExternalUrl(Uri.parse(primary.url)),
            ),
            if (description.isNotEmpty) ...[
              const Gap(16),
              Text(
                description,
                style: theme.typography.body.sm.copyWith(height: 1.45),
              ),
            ],
          ] else if (item.isFilm) ...[
            KaryaFilmStage(
              item: item,
              watchLabel: watch?.label,
              onWatch: watch == null
                  ? null
                  : () => launchExternalUrl(Uri.parse(watch.url)),
              trailerLabel: trailer == null
                  ? null
                  : (trailer.label.trim().isEmpty
                      ? l10n.karyaAccessKindTrailer
                      : trailer.label),
              onTrailer: trailer == null
                  ? null
                  : () => launchExternalUrl(Uri.parse(trailer.url)),
            ),
            if (description.isNotEmpty) ...[
              const Gap(16),
              Text(
                description,
                style: theme.typography.body.sm.copyWith(height: 1.45),
              ),
            ],
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Text(kindLabel),
                ),
                if (item.year != null)
                  FBadge(
                    variant: FBadgeVariant.outline,
                    child: Text(l10n.karyaYearLabel(item.year!)),
                  ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const Gap(12),
              Text(
                description,
                style: theme.typography.body.sm.copyWith(height: 1.45),
              ),
            ],
          ],
          const Gap(18),
          Text(
            l10n.karyaSambasSection,
            style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (item.sambasConnections.isEmpty)
            Text(
              l10n.karyaSambasEmpty,
              style: theme.typography.body.xs.copyWith(
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
          if (item.related.isNotEmpty) ...[
            const Gap(18),
            Text(
              l10n.karyaRelatedSection,
              style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            FTileGroup(
              children: [
                for (final row in item.related)
                  FTile(
                    title: Text(row.title),
                    subtitle: Text(_relatedKindLabel(l10n, row.kind)),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: () => _openRelated(context, row),
                  ),
              ],
            ),
          ],
          const Gap(18),
          Text(
            l10n.karyaCredits,
            style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          FTileGroup(
            children: [
              for (final credit in item.credits)
                FTile(
                  title: Text(credit.nameText),
                  subtitle: Text(_creditRoleLabel(l10n, item.kind, credit.role)),
                  suffix: (credit.kreatorSlug ?? '').isEmpty
                      ? null
                      : Icon(
                          FLucideIcons.chevronRight,
                          size: 16,
                          color: theme.colors.mutedForeground,
                        ),
                  onPress: (credit.kreatorSlug ?? '').isEmpty
                      ? null
                      : () => context.push(
                            KaryaRouter.kreatorPath(credit.kreatorSlug!),
                          ),
                ),
            ],
          ),
          const Gap(18),
          Text(
            l10n.karyaAccess,
            style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (item.accessLinks.isEmpty)
            Text(
              l10n.karyaAccessEmpty,
              style: theme.typography.body.xs.copyWith(
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
                onPress: () => _openContribute(context),
              ),
            ],
          ),
          const Gap(18),
          Text(
            l10n.karyaExcerptSection,
            style:
                theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          if (item.excerpts.isEmpty)
            Text(
              l10n.karyaExcerptEmpty,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            ...item.excerpts.map(
              (excerpt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (excerpt.kind == 'lyrics' || excerpt.kind == 'dialogue')
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _excerptKindLabel(l10n, excerpt.kind),
                                style: theme.typography.body.xs.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                excerpt.text,
                                style: theme.typography.body.sm.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      FTileGroup(
                        children: [
                          FTile(
                            title: Text(excerpt.text, maxLines: 6),
                            subtitle:
                                Text(_excerptKindLabel(l10n, excerpt.kind)),
                          ),
                        ],
                      ),
                    if (excerpt.activeLemmaLinks.isNotEmpty) ...[
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final link in excerpt.activeLemmaLinks)
                            GestureDetector(
                              onTap: () => context.push(
                                DictionaryRouter.detail.path.replaceFirst(
                                  ':id',
                                  Uri.encodeComponent(link.wordId),
                                ),
                              ),
                              child: FBadge(
                                child: Text(
                                  (link.lemma ?? '').trim().isNotEmpty
                                      ? link.lemma!
                                      : '-',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const Gap(8),
                    FTileGroup(
                      children: [
                        FTile(
                          prefix: _linkingExcerptId == excerpt.id
                              ? const FCircularProgress(size: .sm)
                              : Icon(
                                  FLucideIcons.link2,
                                  size: 18,
                                  color: theme.colors.primary,
                                ),
                          title: Text(l10n.karyaLemmaLinkAction),
                          suffix: Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                            color: theme.colors.mutedForeground,
                          ),
                          onPress: _linkingExcerptId == excerpt.id
                              ? null
                              : () => _linkLemma(context, excerpt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const Gap(8),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.quote,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.karyaProposeExcerpt),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => _openExcerpt(context),
              ),
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
                onPress: () => _openContribute(context),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _linkLemma(BuildContext context, KaryaExcerpt excerpt) async {
    final l10n = AppLocalizations.of(context);
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      await showAppErrorSheet(context, message: l10n.karyaLemmaLinkLoginFirst);
      return;
    }
    final picked = await showJinyeWordPickerSheet(context);
    if (!context.mounted || picked == null) return;

    final span = _firstLemmaSpan(excerpt.text, picked.lemma);
    if (span == null) {
      await showAppErrorSheet(context, message: l10n.karyaLemmaLinkNotFoundInText);
      return;
    }

    setState(() => _linkingExcerptId = excerpt.id);
    try {
      await ref.read(karyaApiProvider).createLemmaLink(
            excerptId: excerpt.id,
            start: span.$1,
            end: span.$2,
            wordId: picked.id,
          );
      if (!context.mounted) return;
      ref.invalidate(karyaBySlugProvider(widget.slug));
      showFToast(context: context, title: Text(l10n.karyaLemmaLinkSuccess));
    } catch (e) {
      if (!context.mounted) return;
      final msg = karyaErrorMessage(e);
      await showAppErrorSheet(
        context,
        message: msg.isNotEmpty ? msg : l10n.karyaLemmaLinkFailed,
      );
    } finally {
      if (context.mounted) setState(() => _linkingExcerptId = null);
    }
  }

  void _openContribute(BuildContext context) {
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

  void _openExcerpt(BuildContext context) {
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    context.push(
      KaryaRouter.excerptPath(
        karyaId: item.id,
        slug: item.slug,
        karyaKind: item.kind,
      ),
    );
  }

  String _excerptKindLabel(AppLocalizations l10n, String kind) =>
      switch (kind) {
        'lyrics' => l10n.karyaExcerptKindLyrics,
        'dialogue' => l10n.karyaExcerptKindDialogue,
        'book_quote' => l10n.karyaExcerptKindBookQuote,
        'other' => l10n.karyaExcerptKindOther,
        _ => kind,
      };

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
        'trailer' => l10n.karyaAccessKindTrailer,
        'buy' => l10n.karyaAccessKindBuy,
        'read' => l10n.karyaAccessKindRead,
        'stream' => l10n.karyaAccessKindStream,
        'official' => l10n.karyaAccessKindOfficial,
        'other' => l10n.karyaAccessKindOther,
        _ => kind,
      };

  void _openRelated(BuildContext context, KaryaRelatedItem row) {
    final slug = row.slug;
    switch (row.kind) {
      case 'karya':
        if (slug != null && slug.isNotEmpty) {
          context.push(KaryaRouter.detailPath(slug));
        }
        return;
      case 'kreator':
        if (slug != null && slug.isNotEmpty) {
          context.push(KaryaRouter.kreatorPath(slug));
        }
        return;
      case 'word':
        context.push(
          DictionaryRouter.detail.path.replaceFirst(':id', row.id),
        );
        return;
      case 'place':
        if (slug != null && slug.isNotEmpty) {
          context.push(
            ExploreRouter.place.path.replaceFirst(':slug', slug),
          );
        }
        return;
      case 'event':
        if (slug != null && slug.isNotEmpty) {
          context.push(EventRouter.detailPath(slug));
        }
        return;
      case 'article':
        if (slug != null && slug.isNotEmpty) {
          context.push(EncyclopediaRouter.detailPath(slug));
        }
        return;
      case 'usaha':
        if (slug != null && slug.isNotEmpty) {
          context.push(UsahaRouter.detailPath(slug));
        }
        return;
    }
  }

  String _relatedKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
        'place' => l10n.karyaRelatedKindPlace,
        'word' => l10n.karyaRelatedKindWord,
        'article' => l10n.karyaRelatedKindArticle,
        'event' => l10n.karyaRelatedKindEvent,
        'usaha' => l10n.karyaRelatedKindUsaha,
        'kreator' => l10n.karyaRelatedKindKreator,
        'karya' => l10n.karyaRelatedKindKarya,
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

(int, int)? _firstLemmaSpan(String haystack, String lemma) {
  final needle = lemma.trim();
  if (needle.isEmpty) return null;
  final idx = haystack.toLowerCase().indexOf(needle.toLowerCase());
  if (idx < 0) return null;
  return (idx, idx + needle.length);
}