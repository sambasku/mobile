import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../providers/event_providers.dart';
import '../widgets/event_comments_section.dart';
import '../widgets/event_ui.dart';
import '../../../../l10n/app_localizations.dart';

/// Rasio poster hero detail acara (sama dengan hero wisata).
const _heroAspect = 16 / 10;

/// Share nama, jadwal, lokasi, dan URL kanonik `/id/acara/<slug>`.
Future<void> shareEventPublicLink(BuildContext context, Event event) async {
  final text = eventShareText(event);
  if (text.trim().isEmpty) return;
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

String eventGoingCountLabel(AppLocalizations l10n, Event event) {
  final count = event.goingCount;
  if (event.viewerGoing) {
    if (count <= 1) return l10n.eventGoingCountYou;
    return l10n.eventGoingCountYouAndOthers(count - 1);
  }
  if (count <= 0) return l10n.eventGoingCountZero;
  if (count == 1) return l10n.eventGoingCountOne;
  return l10n.eventGoingCountMany(count);
}

/// Detail acara by slug.
class EventDetailPage extends HookConsumerWidget {
  const EventDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventBySlugProvider(slug));
    final l10n = AppLocalizations.of(context);
    final busy = useState(false);
    final localGoing = useState<({int count, bool going})?>(null);

    final event = eventAsync.asData?.value;
    final goingCount = localGoing.value?.count ?? event?.goingCount ?? 0;
    final viewerGoing = localGoing.value?.going ?? event?.viewerGoing ?? false;
    final displayEvent = event?.copyWithGoing(
      goingCount: goingCount,
      viewerGoing: viewerGoing,
    );

    Future<void> toggleGoing() async {
      final current = displayEvent;
      if (current == null || busy.value || !current.canToggleGoing) return;
      final auth = ref.read(authStatusProvider).value;
      if (auth?.isAuth != true) {
        if (!context.mounted) return;
        showFToast(context: context, title: Text(l10n.eventGoingLoginGate));
        context.push(AuthRouter.login.path);
        return;
      }
      busy.value = true;
      try {
        final repo = ref.read(eventRepositoryProvider);
        final result = current.viewerGoing
            ? await repo.unmarkGoing(current.id)
            : await repo.markGoing(current.id);
        if (!context.mounted) return;
        localGoing.value = (
          count: result.goingCount,
          going: result.viewerGoing,
        );
        showFToast(
          context: context,
          title: Text(
            result.viewerGoing
                ? l10n.eventGoingToastMarked
                : l10n.eventGoingToastUnmarked,
          ),
        );
        ref.invalidate(eventBySlugProvider(slug));
      } catch (_) {
        if (!context.mounted) return;
        await showAppErrorSheet(context, message: l10n.eventGoingToggleFailed);
      } finally {
        busy.value = false;
      }
    }

    // childPad false: hero poster full-bleed (pola detail wisata).
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(l10n.eventListTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
        suffixes: [
          if (displayEvent != null)
            FHeaderAction(
              icon: const Icon(FLucideIcons.share2),
              semanticsLabel: l10n.shareShare,
              onPress: () => shareEventPublicLink(context, displayEvent),
            ),
        ],
      ),
      footer: _buildDetailFooter(
        context: context,
        eventId: event?.id,
        displayEvent: displayEvent,
        busy: busy.value,
        toggleGoing: toggleGoing,
        l10n: l10n,
      ),
      child: eventAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) => const _ErrorBody(),
        data: (event) {
          if (event == null) return const _NotFoundBody();
          return _Body(event: displayEvent ?? event);
        },
      ),
    );
  }
}

/// Footer detail acara: going button di atas + comment entry bar di bawah.
/// SafeArea gesture bar hanya di-consume oleh satu elemen terbawah.
Widget? _buildDetailFooter({
  required BuildContext context,
  required String? eventId,
  required Event? displayEvent,
  required bool busy,
  required VoidCallback toggleGoing,
  required AppLocalizations l10n,
}) {
  final canGoing = displayEvent != null && displayEvent.canToggleGoing;
  final hasComments = eventId != null;

  if (!canGoing && !hasComments) return null;

  if (canGoing && hasComments) {
    // Going button tanpa SafeArea bottom; EventCommentEntryBar handle inset.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: FButton(
            onPress: busy ? null : toggleGoing,
            prefix: busy ? const FCircularProgress() : null,
            child: Text(
              displayEvent.viewerGoing
                  ? l10n.eventGoingCtaUnmark
                  : l10n.eventGoingCtaMark,
            ),
          ),
        ),
        EventCommentEntryBar(eventId: eventId),
      ],
    );
  }

  if (hasComments) return EventCommentEntryBar(eventId: eventId);

  // Hanya going button - SafeArea seperti semula.
  return SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: FButton(
        onPress: busy ? null : toggleGoing,
        prefix: busy ? const FCircularProgress() : null,
        child: Text(
          displayEvent!.viewerGoing
              ? l10n.eventGoingCtaUnmark
              : l10n.eventGoingCtaMark,
        ),
      ),
    ),
  );
}

class _Body extends StatefulWidget {
  const _Body({required this.event});

  final Event event;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) return;
      unawaited(
        AnalyticsService.instance.logEventOpen(slug: widget.event.slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final source = event.sourceUrl;
    final sourceLabel = eventSourceTypeLabel(
      AppLocalizations.of(context),
      event.sourceType,
    );
    final attribution = event.sourceAttribution;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _PosterCarousel(event: event),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: theme.typography.body.xl.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const Gap(8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  eventOccurrenceBadge(l10n, event.effectiveOccurrenceStatus),
                  if (event.category != null)
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text(event.category!.name),
                    ),
                  if (sourceLabel != null)
                    FBadge(
                      variant: FBadgeVariant.outline,
                      child: Text(sourceLabel),
                    ),
                ],
              ),
              // Meta atas: apresiasi pengusul sebelum info/deskripsi.
              if (event.author case final author?)
                ContributorAppreciationSection(
                  label: l10n.usahaContributorProposedBy,
                  contributors: [
                    ContributorCredit(
                      username: author.username,
                      displayName: author.displayName,
                    ),
                  ],
                ),
              const Gap(12),
              Text(
                eventGoingCountLabel(l10n, event),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              _InfoGroup(event: event),
              if (event.description.isNotEmpty) ...[
                const Gap(16),
                Text(
                  event.description,
                  style: theme.typography.body.sm.copyWith(height: 1.5),
                ),
              ],
              if (event.places.isNotEmpty) ...[
                const Gap(20),
                Text(
                  l10n.eventDetailRelatedPlaces,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                FTileGroup(
                  children: [
                    for (final place in event.places)
                      FTile(
                        title: Text(place.name),
                        prefix: const Icon(FLucideIcons.mapPinned, size: 18),
                        onPress: () =>
                            context.push('/explore/place/${place.slug}'),
                      ),
                  ],
                ),
              ],
              // Sumber resmi: chip + icon link (jangan tampilkan URL/HTML mentah).
              if (source != null && source.isNotEmpty) ...[
                const Gap(20),
                Text(
                  l10n.eventDetailOfficialSource,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                _OfficialSourceChips(
                  rawSource: source,
                  sourceTypeLabel: sourceLabel,
                  attribution: attribution,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PosterCarousel extends StatefulWidget {
  const _PosterCarousel({required this.event});

  final Event event;

  @override
  State<_PosterCarousel> createState() => _PosterCarouselState();
}

class _PosterCarouselState extends State<_PosterCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final posters = widget.event.posterUrls;
    return AspectRatio(
      aspectRatio: _heroAspect,
      child: ColoredBox(
        color: theme.colors.secondary,
        child: posters.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FLucideIcons.imageOff,
                      size: 36,
                      color: theme.colors.mutedForeground,
                    ),
                    const Gap(8),
                    Text(
                      l10n.eventDetailNoPoster,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: posters.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final poster = posters[i];
                      return GestureDetector(
                        onTap: () => showImagePreview(
                          context,
                          urls: posters,
                          initialIndex: i,
                        ),
                        child: CachedNetworkImageWithFallback(
                          imageUrl:
                              displayImageUrl(poster, width: 1200) ?? poster,
                          fallbackUrl: poster,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  if (posters.length > 1)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.eventDetailPosterCounter(
                            _index + 1,
                            posters.length,
                          ),
                          style: theme.typography.body.xs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Info utama acara (jadwal, lokasi, desa, penyelenggara) dalam satu
/// FTileGroup - selaras pola detail wisata.
class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final villageSlug = event.village?.slug;
    // Mulai & selesai dipisah - FTile title 1 baris memotong
    // "17 Nov 2026 21:00 - 18 Nov 2026 23:00".
    // Icon di title (bukan prefix): Forui selalu center-vertikal prefix.
    return FTileGroup(
      children: [
        _topIconInfoTile(
          icon: FLucideIcons.calendarClock,
          title: l10n.eventStart,
          subtitle: formatDateTime(event.startsAt),
          subtitleMaxLines: 2,
        ),
        _topIconInfoTile(
          icon: FLucideIcons.calendarCheck,
          title: l10n.eventEnd,
          subtitle: formatDateTime(event.endsAt),
          subtitleMaxLines: 2,
        ),
        if (event.locationText.isNotEmpty)
          _topIconInfoTile(
            icon: FLucideIcons.mapPin,
            title: l10n.eventDetailAddress,
            subtitle: event.locationText,
            subtitleMaxLines: 3,
            titleSpacing: 8,
          ),
        // Desa opsional; tap = detail desa (slug = kode BPS).
        if (event.village != null)
          FTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(FLucideIcons.building2, size: 18),
                const Gap(10),
                Expanded(
                  child: Text(l10n.eventDetailVillage(event.village!.name)),
                ),
              ],
            ),
            suffix: villageSlug == null
                ? null
                : const Icon(FLucideIcons.chevronRight, size: 16),
            onPress: villageSlug == null
                ? null
                : () => context.push(
                    '/explore/desa/${Uri.encodeComponent(villageSlug)}',
                  ),
          ),
        // Penyelenggara opsional - label kosong di-skip (PRD 6.2).
        if (event.organizer != null && event.organizer!.isNotEmpty)
          _topIconInfoTile(
            icon: FLucideIcons.users,
            title: l10n.eventFormOrganizerLabel,
            subtitle: event.organizer!,
            subtitleMaxLines: 3,
            titleSpacing: 8,
          ),
      ],
    );
  }
}

/// Tile info dengan icon top-aligned (Forui prefix selalu di-center).
FTile _topIconInfoTile({
  required IconData icon,
  required String title,
  required String subtitle,
  int subtitleMaxLines = 1,
  double titleSpacing = 3,
}) {
  const iconSize = 18.0;
  const iconGap = 10.0;
  return FTile(
    style: .delta(contentStyle: .delta(titleSpacing: titleSpacing)),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize),
        const Gap(iconGap),
        Expanded(child: Text(title)),
      ],
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(left: iconSize + iconGap),
      child: Text(
        subtitle,
        maxLines: subtitleMaxLines,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: subtitleMaxLines > 1 ? const TextStyle(height: 1.45) : null,
      ),
    ),
  );
}

/// Chip tautan sumber resmi - label bersih, bukan URL/HTML mentah.
class _OfficialSourceChips extends StatelessWidget {
  const _OfficialSourceChips({
    required this.rawSource,
    this.sourceTypeLabel,
    this.attribution,
  });

  final String rawSource;
  final String? sourceTypeLabel;
  final String? attribution;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final uris = _parseSourceUris(rawSource);
    if (uris.isEmpty) return const SizedBox.shrink();

    final cleanAttribution = _stripHtml(attribution ?? '');
    final chips = <Widget>[
      for (final uri in uris)
        _SourceChip(
          label: _chipLabel(
            uri: uri,
            sourceTypeLabel: sourceTypeLabel,
            single: uris.length == 1,
            fallback: l10n.announcementOpenLink,
          ),
          onPress: () => launchExternalUrl(uri),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        // Atribusi hanya caption muted - jangan jadi label chip
        // (bisa mirip nama pengusul).
        if (cleanAttribution.isNotEmpty) ...[
          const Gap(6),
          Text(
            cleanAttribution,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  static String _chipLabel({
    required Uri uri,
    required String? sourceTypeLabel,
    required bool single,
    required String fallback,
  }) {
    if (single && sourceTypeLabel != null && sourceTypeLabel.isNotEmpty) {
      return sourceTypeLabel;
    }
    final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
    if (host.isNotEmpty) return host;
    return fallback;
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label, required this.onPress});

  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      button: true,
      label: label,
      child: FTappable(
        onPress: onPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(8),
                Icon(
                  FLucideIcons.externalLink,
                  size: 14,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ambil URL dari plain string atau markup HTML (`href="..."`).
List<Uri> _parseSourceUris(String raw) {
  final hrefs = RegExp(
    r'''href\s*=\s*["']([^"']+)["']''',
    caseSensitive: false,
  ).allMatches(raw).map((m) => m.group(1)!.trim()).toList();
  final candidates = hrefs.isNotEmpty
      ? hrefs
      : [raw.trim().split(RegExp(r'\s+')).first];
  final out = <Uri>[];
  final seen = <String>{};
  for (final c in candidates) {
    final uri = Uri.tryParse(c);
    if (uri == null) continue;
    if (uri.scheme != 'http' && uri.scheme != 'https') continue;
    final key = uri.toString();
    if (!seen.add(key)) continue;
    out.add(uri);
  }
  return out;
}

String _stripHtml(String raw) => raw
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.calendarX,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.eventDetailNotFound,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(EventRouter.list.path),
              child: Text(l10n.eventDetailSeeList),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.eventDetailLoadFailed,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(EventRouter.list.path),
              child: Text(l10n.eventDetailSeeList),
            ),
          ],
        ),
      ),
    );
  }
}
