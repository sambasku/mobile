import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/public_account_name.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../explore/explore_router.dart';
import '../../../event/event_router.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/utils/open_pending_word_review.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../usaha/usaha_router.dart';
import '../../activity_router.dart';
import '../../domain/entities/feed_activity_item.dart';
import 'activity_kind_avatar.dart';
import '../../../../l10n/app_localizations.dart';

/// Satu baris feed "Aktivitas terbaru" (home + profil publik).
class ActivityFeedTile extends ConsumerWidget {
  const ActivityFeedTile({super.key, required this.item, this.showCta = true});

  final FeedActivityItem item;

  /// false = sembunyikan label CTA + chevron di kanan (mis. profil sendiri,
  /// aksi ke karya sendiri tidak relevan). Tap baris tetap navigasi.
  final bool showCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final l10n = AppLocalizations.of(context);
    final actorLabel = item.actor == null
        ? l10n.feedActorFallback
        : displayPublicAccountLabel(
            displayName: item.actor!.displayName,
            username: item.actor!.username,
          );
    final canOpenProfile = isLinkablePublicUsername(item.actor?.username);
    final dateLabel = formatRelativeCompact(DateTime.tryParse(item.createdAt));
    final kindLabel = _friendlyKindLabel(item.kind, l10n);
    final subtitle = item.subtitle?.trim();
    final contextMeta = [
      ?kindLabel,
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
    ].join(' · ');

    /// #166 / #179: usulan kata baru pending. Verifikator buka sesi
    /// Setujui/Tolak untuk kontribusi itu (bukan antrean yang sering kosong).
    /// Tamu hanya dapat info: kata belum tayang di mana pun.
    final isPendingSubmission =
        item.kind == FeedActivityKind.contribution &&
        item.target?.status == 'pending_review';
    final canReview = canReviewQueue(auth?.role);
    final opensPendingReview = isPendingSubmission && canReview;
    final path = _navigatePath(item);
    // CTA "Lihat kata" untuk kata published; "Tinjau usulan" hanya verifikator
    // pada usulan pending. Pending+tamu: toast, tidak ada CTA label
    // (baris tetap bisa ditap).
    final showCtaLabel =
        switch (item.kind) {
          FeedActivityKind.contribution => !(isPendingSubmission && !canReview),
          _ => true,
        } &&
        showCta &&
        (path != null || opensPendingReview);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canOpenProfile
              ? () => UserProfileRouter.open(context, item.actor!.username!)
              : null,
          child: ActivityKindAvatar(
            kind: item.kind,
            imageUrl: item.actor?.avatarUrl,
            name: actorLabel,
            size: 40,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: PublicAccountName(
                      label: actorLabel,
                      isVerifier: item.actor?.isVerifier ?? false,
                      onTap: canOpenProfile
                          ? () => UserProfileRouter.open(
                              context,
                              item.actor!.username!,
                            )
                          : null,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: canOpenProfile
                            ? theme.colors.primary
                            : theme.colors.foreground,
                      ),
                    ),
                  ),
                  if (dateLabel.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      dateLabel,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
              if (canOpenProfile)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      UserProfileRouter.open(context, item.actor!.username!),
                  child: Text(
                    '@${item.actor!.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ),
              const Gap(4),
              Text.rich(
                TextSpan(
                  children: [
                    // Komentar/diskusi = teks bebas user; kutipannya bukan lemma.
                    for (final (text, lemma) in switch (item.kind) {
                      FeedActivityKind.comment ||
                      FeedActivityKind.discussion => [(item.body, false)],
                      _ => splitQuotedLemma(item.body),
                    })
                      TextSpan(
                        text: text,
                        style: lemma
                            ? const TextStyle(fontWeight: FontWeight.w700)
                            : null,
                      ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  height: 1.35,
                  color: theme.colors.foreground,
                ),
              ),
              if (contextMeta.isNotEmpty || path != null) ...[
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contextMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.25,
                        ),
                      ),
                    ),
                    // CTA hanya label; tap ditangani InkWell baris (tujuan sama).
                    // Sengaja muted: fokus visual tetap di lemma, bukan CTA.
                    if (showCtaLabel) ...[
                      const Gap(8),
                      Text(
                        _ctaLabel(
                          item.kind,
                          l10n,
                          pendingReview: isPendingSubmission && canReview,
                        ),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        // #179: verifikator pada usulan pending → sesi Setujui/Tolak.
        // #166: tanpa akses review = tap toast (bukan dead row).
        // Baris tanpa tujuan = onTap null (tidak ada ripple menyesatkan).
        onTap: (path == null && !isPendingSubmission)
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (isPendingSubmission && !canReview) {
                  showFToast(
                    context: context,
                    title: Text(l10n.feedPendingToast),
                  );
                  return;
                }
                if (opensPendingReview) {
                  final wordId = item.target?.id;
                  if (wordId != null && wordId.isNotEmpty) {
                    unawaited(openPendingWordReview(context, ref, wordId));
                  }
                  return;
                }
                // #102: pengumuman bawa payload beku (detail tanpa fetch ulang).
                context.push(path!, extra: item.announcement);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: content,
        ),
      ),
    );
  }

  /// Label singkat non-teknis di meta (bukan entity_type mentah).
  static String? _friendlyKindLabel(FeedActivityKind kind, AppLocalizations l10n) {
    return switch (kind) {
      FeedActivityKind.word => l10n.feedKindWord,
      FeedActivityKind.comment => l10n.feedKindComment,
      FeedActivityKind.vote ||
      FeedActivityKind.voteUp ||
      FeedActivityKind.voteDown => l10n.feedKindVote,
      FeedActivityKind.discussion => l10n.feedKindDiscussion,
      FeedActivityKind.wordImage => l10n.feedKindImage,
      FeedActivityKind.wordAudio => l10n.feedKindAudio,
      FeedActivityKind.pronunciation => l10n.feedKindPronunciation,
      FeedActivityKind.example => l10n.feedKindExample,
      FeedActivityKind.searchMiss => l10n.feedKindSearchMiss,
      FeedActivityKind.welcome => l10n.feedKindWelcome,
      FeedActivityKind.cardShare => l10n.feedKindShare,
      FeedActivityKind.suggestion => l10n.feedKindSuggestion,
      FeedActivityKind.contribution => l10n.feedKindContribution,
      FeedActivityKind.verification => l10n.feedKindVerification,
      FeedActivityKind.announcement => l10n.feedKindAnnouncement,
      FeedActivityKind.placePhoto => l10n.feedKindPlacePhoto,
      FeedActivityKind.placeListing => l10n.feedKindPlace,
      FeedActivityKind.event => l10n.feedKindEvent,
      FeedActivityKind.usaha => l10n.feedKindUsaha,
      FeedActivityKind.culinary => l10n.feedKindCulinary,
    };
  }

  static String _ctaLabel(
    FeedActivityKind kind,
    AppLocalizations l10n, {
    bool pendingReview = false,
  }) {
    // #166: usulan pending → CTA tinjau, bukan buka detail.
    if (pendingReview && kind == FeedActivityKind.contribution) {
      return l10n.feedCtaReview;
    }
    return switch (kind) {
      FeedActivityKind.vote ||
      FeedActivityKind.voteUp ||
      FeedActivityKind.voteDown => l10n.feedCtaVote,
      FeedActivityKind.word => l10n.feedCtaSeeMeaning,
      FeedActivityKind.comment => l10n.feedCtaReply,
      FeedActivityKind.discussion => l10n.feedCtaDiscuss,
      FeedActivityKind.wordImage => l10n.feedCtaSeePhoto,
      FeedActivityKind.wordAudio => l10n.feedCtaListen,
      FeedActivityKind.pronunciation => l10n.feedCtaSeePronunciation,
      FeedActivityKind.example => l10n.feedCtaSeeExample,
      FeedActivityKind.searchMiss => l10n.feedCtaHelpFill,
      FeedActivityKind.welcome => l10n.feedCtaSeeProfile,
      FeedActivityKind.cardShare => l10n.feedCtaSeeCard,
      FeedActivityKind.suggestion => l10n.feedCtaSeeSuggestion,
      FeedActivityKind.contribution ||
      FeedActivityKind.verification => l10n.feedCtaSeeWord,
      FeedActivityKind.announcement => l10n.feedCtaReadAnnouncement,
      FeedActivityKind.placePhoto ||
      FeedActivityKind.placeListing => l10n.feedCtaSeePlace,
      FeedActivityKind.event => l10n.feedCtaSeeEvent,
      FeedActivityKind.usaha => l10n.feedCtaSeeUsaha,
      FeedActivityKind.culinary => l10n.feedCtaSeeCulinary,
    };
  }

  String? _navigatePath(FeedActivityItem item) {
    final target = item.target;
    if (target == null) return null;
    switch (target.type) {
      case 'word':
        // #179: usulan pending tidak punya path statis. Verifikator lookup
        // kontribusi lalu buka sesi; tamu toast. Detail publik 404.
        if (item.kind == FeedActivityKind.contribution &&
            target.status == 'pending_review') {
          return null;
        }
        return DictionaryRouter.detail.path.replaceFirst(':id', target.id);
      case 'announcement':
        // #102: payload beku diteruskan via extra - detail tanpa fetch ulang.
        return ActivityRouter.announcementDetail.path.replaceFirst(
          ':id',
          target.id,
        );
      case 'discussion':
        return DiscussionRouter.detailPath(target.id);
      case 'place':
        // #187: target = slug tempat (bukan ULID) - detail publik mobile.
        return ExploreRouter.place.path.replaceFirst(':slug', target.id);
      case 'event':
        // target = slug acara (bukan ULID) - detail publik mobile.
        return EventRouter.detail.path.replaceFirst(':slug', target.id);
      case 'usaha':
        // target = slug usaha (bukan ULID) - detail publik mobile.
        return UsahaRouter.detailPath(target.id);
      case 'culinary':
        // target = slug kuliner (bukan ULID) - detail publik mobile.
        return ExploreRouter.cuisineDetail.path.replaceFirst(
          ':slug',
          target.id,
        );
      case 'culinary_place':
        // Belum ada halaman detail tempat kuliner - arahkan ke daftar.
        return ExploreRouter.cuisinePlaces.path;
      case 'user':
        final username = item.actor?.username?.trim();
        if (username == null ||
            username.isEmpty ||
            !isLinkablePublicUsername(username)) {
          return null;
        }
        return UserProfileRouter.profile.path.replaceFirst(
          ':username',
          Uri.encodeComponent(username),
        );
      case 'search_miss':
        final term = _searchMissTerm(item);
        // #144: arah search-miss untuk memilih field prefill yang tepat di
        // form usul (direction 'translation' → kata Indonesia ke padanan).
        final searchIn = target.direction;
        final q = Uri(
          queryParameters: <String, String>{
            if (term != null && term.isNotEmpty) 'lemma': term,
            'search_in': ?searchIn,
            'miss_id': target.id,
          },
        ).query;
        return '${ContributionRouter.contribute.path}?$q';
      default:
        return null;
    }
  }

  String? _searchMissTerm(FeedActivityItem item) {
    // Baru: Mencari "term" - belum ada...
    // Lama: mencari term tapi tidak terdapat...
    final body = item.body;
    final quoted = RegExp(r'Mencari "([^"]+)"').firstMatch(body);
    if (quoted != null) return quoted.group(1)?.trim();
    const prefix = 'mencari ';
    const suffix = ' tapi tidak terdapat';
    if (!body.startsWith(prefix) || !body.contains(suffix)) return null;
    return body.substring(prefix.length, body.indexOf(suffix)).trim();
  }
}
