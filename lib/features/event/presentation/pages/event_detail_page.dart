import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/entity_comments/entity_comment.dart';
import '../../../../shared/entity_comments/entity_comments_section.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/contributor_appreciation.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../providers/event_providers.dart';
import '../../domain/event_schedule_format.dart';
import '../widgets/event_ui.dart';

/// Rasio poster hero detail acara (sama dengan hero wisata).
const _heroAspect = 16 / 10;

/// Detail acara by slug.
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventBySlugProvider(slug));
    final l10n = AppLocalizations.of(context);

    final event = eventAsync.asData?.value;
    // childPad false: hero poster full-bleed (pola detail wisata).
    return FScaffold(
      childPad: false,
      // EntryBar sudah punya top border - jangan dobel dengan footerDecoration.
      scaffoldStyle: .delta(
        footerDecoration: .value(const BoxDecoration()),
      ),
      header: FHeader.nested(
        title: Text(l10n.eventListTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      footer: event == null
          ? null
          : EntityCommentEntryBar(
              target: EntityCommentTarget.event,
              entityId: event.id,
            ),
      child: eventAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) => const _ErrorBody(),
        data: (event) {
          if (event == null) return const _NotFoundBody();
          return _Body(event: event);
        },
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.event});

  final Event event;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _goingBusy = false;

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

  /// Toggle presensi "Aku hadir". Guest diarahkan login dulu.
  Future<void> _toggleGoing() async {
    if (_goingBusy) return;
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      context.push('/login');
      return;
    }
    final event = widget.event;
    setState(() => _goingBusy = true);
    final going = !event.viewerGoing;
    try {
      await (going
          ? ref.read(eventRepositoryProvider).markGoing(event.id)
          : ref.read(eventRepositoryProvider).unmarkGoing(event.id));
      // Refresh detail biar going_count + viewer_going baru dari server.
      ref.invalidate(eventBySlugProvider(event.slug));
    } catch (_) {
      // Biarkan state server yang menang; toggle presensi bukan aksi kritikal.
    } finally {
      if (mounted) setState(() => _goingBusy = false);
    }
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(eventBySlugProvider(event.slug));
        ref.invalidate(eventImagePreviewProvider(event.slug));
      },
      child: ListView(
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
                  eventOccurrenceBadge(
                    l10n,
                    event.effectiveOccurrenceStatus,
                  ),
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
            const Gap(16),
            _InfoGroup(
              event: event,
              goingBusy: _goingBusy,
              onGoingToggle: _toggleGoing,
            ),
            const Gap(12),
            _PhotoGrid(slug: event.slug),
            if (event.description.isNotEmpty) ...[
              const Gap(16),
              Text(
                  event.description,
                  style: theme.typography.body.sm.copyWith(height: 1.5),
                ),
              ],
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
              // Link sumber resmi: tampil hanya kalau ada (PRD 6.1).
              if (source != null && source.isNotEmpty) ...[
                const Gap(20),
                Text(
                  l10n.eventDetailOfficialSource,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () => _openSource(context, source),
                  child: Text(
                    source,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (attribution != null && attribution.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    attribution,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
      ),
    );
  }

  /// Buka link sumber resmi. UTM referal disisip otomatis oleh
  /// [launchExternalUrl] (helper UTM global).
  void _openSource(BuildContext context, String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    launchExternalUrl(uri);
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

/// Info utama acara (jadwal, lokasi, desa, penyelenggara, presensi,
/// tambah foto) dalam satu FTileGroup - selaras pola detail wisata.
class _InfoGroup extends ConsumerWidget {
  const _InfoGroup({
    required this.event,
    required this.goingBusy,
    required this.onGoingToggle,
  });

  final Event event;
  final bool goingBusy;
  final VoidCallback onGoingToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider).value;
    final villageSlug = event.village?.slug;
    // Mulai & selesai dipisah - FTile title 1 baris memotong
    // "17 Nov 2026 21:00 - 18 Nov 2026 23:00".
    return FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FLucideIcons.calendarClock, size: 18),
          title: Text(l10n.eventStart),
          subtitle: Text(
            formatEventSchedule(l10n, event),
            maxLines: 2,
            softWrap: true,
          ),
        ),
        if (event.locationText.isNotEmpty)
          FTile(
            prefix: const Icon(FLucideIcons.mapPin, size: 18),
            title: Text(l10n.eventDetailAddressLabel),
            subtitle: Text(
              event.locationText,
              maxLines: 4,
              softWrap: true,
            ),
          ),
        // Desa opsional; tap = detail desa (slug = kode BPS).
        if (event.village != null)
          FTile(
            prefix: const Icon(FLucideIcons.building2, size: 18),
            title: Text(l10n.eventDetailVillage(event.village!.name)),
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
            FTile(
              prefix: const Icon(FLucideIcons.users, size: 18),
              title: Text(l10n.eventDetailOrganizerLabel),
              subtitle: Text(
                event.organizer!,
                maxLines: 4,
                softWrap: true,
              ),
            ),
          // Presensi kehadiran - tile toggle (pola tile kontribusi).
          FTile(
            prefix: goingBusy
                ? const FCircularProgress(size: .sm)
                : Icon(
                    event.viewerGoing
                        ? FLucideIcons.circleCheck
                        : FLucideIcons.userCheck,
                    size: 18,
                  ),
            title: Text(
              event.eventDateReached()
                  ? (event.viewerGoing
                      ? l10n.eventGoingCancelAttend
                      : l10n.eventGoingActionAttend)
                  : (event.viewerGoing
                      ? l10n.eventGoingCancelPlan
                      : l10n.eventGoingActionPlan),
            ),
            subtitle: Text(
              event.eventDateReached()
                  ? l10n.eventGoingCountAttend(event.goingCount)
                  : l10n.eventGoingCountPlan(event.goingCount),
            ),
            onPress: goingBusy ? null : onGoingToggle,
          ),
          // Tambah foto acara - pola wisata: tile aksi + login gate.
          FTile(
            prefix: const Icon(FLucideIcons.image, size: 18),
            title: Text(l10n.eventPhotosUpload),
            subtitle: auth?.isAuth == true
                ? null
                : Text(l10n.placeAddPhotoLoginGate),
            suffix: const Icon(FLucideIcons.chevronRight, size: 16),
            onPress: () => context.push(
              auth?.isAuth == true
                  ? EventRouter.photoAddPath(event.slug)
                  : AuthRouter.login.path,
            ),
          ),
          FTile(
            prefix: const Icon(FLucideIcons.history, size: 18),
            title: Text(l10n.historyTitle),
            subtitle: Text(l10n.eventHistoryBody),
            suffix: const Icon(FLucideIcons.chevronRight, size: 16),
            onPress: () => context.push(EventRouter.historyPath(event.slug)),
          ),
      ],
    );
  }
}

/// Pratinjau 3 foto teratas acara (pola _PhotoGrid wisata).
/// Menampilkan link "Lihat lainnya" bila total foto > 3.
class _PhotoGrid extends ConsumerWidget {
  const _PhotoGrid({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(eventImagePreviewProvider(slug));
    return imagesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (page) {
        final images = page.items;
        final theme = context.theme;
        final l10n = AppLocalizations.of(context);
        // Tanpa foto: section disembunyikan - upload lewat tile aksi
        // di _InfoGroup (pola wisata).
        if (images.isEmpty) return const SizedBox.shrink();
        final shown = images.length <= 3 ? images : images.sublist(0, 3);
        final hidden = page.total - shown.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            Text(
              l10n.eventPhotoSection,
              style: theme.typography.body.md
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final img = shown[i];
                return GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    urls: [for (final im in images) im.url],
                    credits: [
                      for (final im in images) im.attribution,
                    ],
                    initialIndex: i,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImageWithFallback(
                      imageUrl: displayImageUrl(img.url, width: 360) ?? img.url,
                      fallbackUrl: img.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            if (hidden > 0) ...[
              const Gap(8),
              GestureDetector(
                onTap: () => context.push(EventRouter.photosPath(slug)),
                child: Text(
                  l10n.eventMorePhotos(hidden),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            // Jalan masuk galeri + upload selalu ada (1-3 foto pun),
            // pola wisata: link "Lihat semua foto".
            const Gap(8),
            GestureDetector(
              onTap: () => context.push(EventRouter.photosPath(slug)),
              child: Text(
                l10n.eventAllPhotos,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
