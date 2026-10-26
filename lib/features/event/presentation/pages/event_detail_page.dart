import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../providers/event_providers.dart';
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

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Acara'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
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

class _Body extends StatelessWidget {
  const _Body({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final source = event.sourceUrl;
    final sourceLabel = eventSourceTypeLabel(event.sourceType);
    final attribution = event.sourceAttribution;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (event.posterUrls.isNotEmpty) ...[
          _PosterCarousel(event: event),
          const Gap(16),
        ],
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
            eventOccurrenceBadge(event.effectiveOccurrenceStatus),
            if (event.category != null)
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text(event.category!.name),
              ),
            if (sourceLabel != null)
              FBadge(variant: FBadgeVariant.outline, child: Text(sourceLabel)),
          ],
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
            'Wisata terkait',
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
                  onPress: () => context.push('/explore/place/${place.slug}'),
                ),
            ],
          ),
        ],
        // Link sumber resmi: tampil hanya kalau ada (PRD 6.1).
        if (source != null && source.isNotEmpty) ...[
          const Gap(20),
          Text(
            'Sumber resmi',
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
    final posters = widget.event.posterUrls;
    return AspectRatio(
      aspectRatio: _heroAspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: posters.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final poster = posters[i];
              return GestureDetector(
                onTap: () =>
                    showImagePreview(context, urls: posters, initialIndex: i),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(poster, width: 1200) ?? poster,
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
                  '${_index + 1}/${posters.length}',
                  style: theme.typography.body.xs.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
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
    final villageSlug = event.village?.slug;
    return FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FLucideIcons.clock, size: 18),
          title: Text(formatEventSchedule(event)),
        ),
        if (event.locationText.isNotEmpty)
          FTile(
            prefix: const Icon(FLucideIcons.mapPin, size: 18),
            title: Text(event.locationText),
          ),
        // Desa opsional; tap = detail desa (slug = kode BPS).
        if (event.village != null)
          FTile(
            prefix: const Icon(FLucideIcons.building2, size: 18),
            title: Text('Desa ${event.village!.name}'),
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
            title: Text('Diselenggarakan oleh ${event.organizer}'),
          ),
      ],
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
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
              'Acara ini tidak ditemukan',
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(EventRouter.list.path),
              child: const Text('Lihat daftar acara'),
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
              'Gagal memuat acara',
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.go(EventRouter.list.path),
              child: const Text('Lihat daftar acara'),
            ),
          ],
        ),
      ),
    );
  }
}
