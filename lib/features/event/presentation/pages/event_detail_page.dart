import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/external_link.dart';
import '../../domain/entities/event.dart';
import '../../event_router.dart';
import '../providers/event_providers.dart';
import '../widgets/event_ui.dart';

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
              FBadge(
                variant: FBadgeVariant.outline,
                child: Text(sourceLabel),
              ),
          ],
        ),
        const Gap(16),
        _InfoRow(
          icon: FLucideIcons.clock,
          text: formatEventSchedule(event),
        ),
        if (event.locationText.isNotEmpty) ...[
          const Gap(8),
          _InfoRow(
            icon: FLucideIcons.mapPin,
            text: event.locationText,
          ),
        ],
        if (event.village != null) ...[
          const Gap(8),
          _InfoRow(
            icon: FLucideIcons.building2,
            text: 'Desa ${event.village!.name}',
          ),
        ],
        // Penyelenggara opsional - label kosong di-skip (PRD 6.2).
        if (event.organizer != null && event.organizer!.isNotEmpty) ...[
          const Gap(8),
          _InfoRow(
            icon: FLucideIcons.users,
            text: 'Diselenggarakan oleh ${event.organizer}',
          ),
        ],
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
                  onPress: () => context.push(
                    '/explore/place/${place.slug}',
                  ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colors.mutedForeground),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
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
