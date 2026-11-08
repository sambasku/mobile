import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/models/external_link.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/image_placeholder_256.dart';
import '../../data/datasources/about_api_datasource.dart';
import '../../../user_profile/user_profile_router.dart';
import '../providers/about_api_providers.dart';

/// Halaman About: identitas app + blok info & fitur. Data Sponsor/Mitra
/// dan Tim Kami pindah ke [SponsorshipTeamPage] supaya tidak duplikat.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  /// Profil organisasi sekaligus daftar repo publik (kode sumber).
  static final Uri githubUri = Uri.parse('https://github.com/sambasku');

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.aboutTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final versionLabel = info == null
              ? '…'
              : '${info.version} (${info.buildNumber})';

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: [
              const BrandMark(size: 112),
              const Gap(8),
              Text(
                AppLocalizations.of(context).aboutTagline,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  height: 1.2,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(2),
              Text(
                AppLocalizations.of(context).aboutVersion(versionLabel),
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  height: 1.2,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              _AboutBlock(title: l10n.aboutWhatTitle, body: l10n.aboutWhatBody),
              const Gap(16),
              _AboutLinkBlock(
                title: l10n.aboutSponsorTitle,
                body: l10n.aboutSponsorBody,
                actionLabel: l10n.aboutSponsorAction,
                onPress: () => context.push('/about/sponsorship'),
              ),
              const Gap(16),
              _AboutLinkBlock(
                title: l10n.aboutSourceTitle,
                body: l10n.aboutSourceBody,
                actionLabel: l10n.aboutSourceAction,
                onPress: () => launchExternalUrl(AboutPage.githubUri),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Halaman khusus dengan dua tab: Sponsor & Mitra, dan Tim Kami.
/// Isi datanya tidak ditampilkan di halaman Tentang supaya tidak duplikat.
class SponsorshipTeamPage extends StatelessWidget {
  const SponsorshipTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.aboutSponsorshipTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/about'),
          ),
        ],
      ),
      child: FTabs(
        expands: true,
        children: [
          FTabEntry.entry(
            label: Text(l10n.aboutTabSponsors),
            child: const _SponsorsTab(),
          ),
          FTabEntry.entry(
            label: Text(l10n.aboutTabTeam),
            child: const _TeamTab(),
          ),
        ],
      ),
    );
  }
}

class _SponsorsTab extends StatelessWidget {
  const _SponsorsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        _AboutBlock(title: l10n.aboutSupportTitle, body: l10n.aboutSupportBody),
        const Gap(16),
        const _SponsorsSection(),
      ],
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        _AboutBlock(
          title: l10n.aboutTogetherTitle,
          body: l10n.aboutTogetherBody,
        ),
        const Gap(16),
        const _TeamCoreSection(),
        const Gap(16),
        _AboutBlock(
          title: l10n.aboutVerifiersTitle,
          body: l10n.aboutVerifiersBody,
        ),
        const Gap(8),
        const _VerifiersSection(),
        const Gap(16),
        const _ContributorsEntry(),
      ],
    );
  }
}

/// Tim Inti: users.is_team (avatar + team_note sebagai subtitle).
class _TeamCoreSection extends ConsumerWidget {
  const _TeamCoreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(aboutTeamProvider);
    final members = async.value;
    if (async.isLoading && members == null) {
      return const _SectionSkeleton(tileCount: 3);
    }
    if (members == null || members.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aboutTeamCoreTitle,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        for (final member in members) ...[
          _PersonAvatarTile(
            username: member.username,
            displayName: member.displayName,
            avatarUrl: member.avatarUrl,
            // Subtitle bebas (bukan role): team_note, fallback team_as data lama.
            subtitle: switch (member.teamNote) {
              final n? when n.isNotEmpty => n,
              _ => member.teamAs,
            },
          ),
          const Gap(8),
        ],
      ],
    );
  }
}

/// Satu baris total. Tap membuka daftar nama (role contributor).
class _ContributorsEntry extends ConsumerWidget {
  const _ContributorsEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(aboutContributorsProvider);
    final state = async.value;
    if (async.isLoading && state == null) {
      return const _SectionSkeleton(tileCount: 1);
    }
    if (state == null || state.total == 0) return const SizedBox.shrink();

    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/about/contributors'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.aboutContributorsTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              Text(
                '${state.total}',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(4),
              Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daftar nama kontributor. Dibuka dari baris total di tab Tim Kami.
class ContributorsListPage extends StatelessWidget {
  const ContributorsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.aboutContributorsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go('/about/sponsorship'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          Text(
            l10n.aboutContributorsBody,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(8),
          const _ContributorsFlatSection(),
        ],
      ),
    );
  }
}

/// Kontributor: nama flat + load more.
class _ContributorsFlatSection extends ConsumerWidget {
  const _ContributorsFlatSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(aboutContributorsProvider);
    final state = async.value;
    if (async.isLoading && state == null) {
      return const _SectionSkeleton(tileCount: 4);
    }
    if (state == null || state.items.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in state.items) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => UserProfileRouter.open(
                context,
                item.username,
                displayName: item.displayName,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.displayName,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (state.hasMore) ...[
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: state.loadingMore
                ? null
                : () => ref.read(aboutContributorsProvider.notifier).loadMore(),
            prefix: state.loadingMore ? const FCircularProgress() : null,
            child: Text(l10n.aboutContributorsLoadMore),
          ),
        ],
      ],
    );
  }
}

/// Verifikator: avatar + nama (apresiasi).
class _VerifiersSection extends ConsumerWidget {
  const _VerifiersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aboutVerifiersProvider);
    final items = async.value;
    if (async.isLoading && items == null) {
      return const _SectionSkeleton(tileCount: 3);
    }
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final v in items) ...[
          _PersonAvatarTile(
            username: v.username,
            displayName: v.displayName,
            avatarUrl: v.avatarUrl,
          ),
          const Gap(8),
        ],
      ],
    );
  }
}

class _PersonAvatarTile extends StatelessWidget {
  const _PersonAvatarTile({
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.subtitle,
    this.note,
  });

  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? subtitle;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tile = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: avatarUrl == null
                  ? const ImagePlaceholder256()
                  : CachedNetworkImageWithFallback(
                      imageUrl: avatarUrl!,
                      fallback: const ImagePlaceholder256(),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              if (subtitle case final s? when s.isNotEmpty)
                Text(
                  s,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              if (note case final n? when n.isNotEmpty) ...[
                const Gap(2),
                Text(
                  n,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
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
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            UserProfileRouter.open(context, username, displayName: displayName),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: tile),
              Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daftar sponsor dari API. Soft-fail bila kosong/gagal.
class _SponsorsSection extends ConsumerWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(aboutSponsorshipsProvider);
    final sponsors = async.value;
    if (async.isLoading && sponsors == null) {
      return const _SectionSkeleton(tileCount: 3);
    }
    if (sponsors == null || sponsors.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.aboutSponsorsSectionTitle,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.foreground,
              ),
            ),
            const Gap(4),
            Tooltip(
              message: l10n.aboutSponsorsTooltip,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 6),
              child: Icon(
                FLucideIcons.info,
                size: 14,
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
        const Gap(4),
        for (final sponsor in sponsors) ...[
          _SponsorTile(sponsor: sponsor),
          const Gap(8),
        ],
      ],
    );
  }
}

class _SponsorTile extends StatelessWidget {
  const _SponsorTile({required this.sponsor});

  final AboutSponsorship sponsor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final note = sponsor.note.trim();

    final tile = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sponsor.logoUrl case final logo?)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CachedNetworkImageWithFallback(
                  imageUrl: logo,
                  fallback: const ImagePlaceholder256(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sponsor.name,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              if (sponsor.description case final desc?) ...[
                const Gap(2),
                Text(
                  desc,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
              if (note.isNotEmpty) ...[
                const Gap(4),
                Text(
                  note,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // #100: sama dengan _ContributorTile - profil SambasKu bila ada.
    // #147: url website -> ikon globe buka browser eksternal.
    final username = sponsor.username;
    if (username == null && sponsor.url == null) return tile;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: username == null
            ? null
            : () => UserProfileRouter.open(
                context,
                username,
                displayName: sponsor.name,
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: tile),
              if (sponsor.url case final url?) _WebsiteAction(url: url),
              if (username != null)
                Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// #147: aksi kecil buka website (url_launcher, browser eksternal).
/// Gagal launch -> toast; tap tidak menjalar ke tap tile (profil).
class _WebsiteAction extends StatelessWidget {
  const _WebsiteAction({required this.url});

  final String url;

  Future<void> _open(BuildContext context) async {
    var ok = false;
    try {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        ok = await launchExternalUrl(uri);
      }
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).aboutOpenWebsiteFailed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).aboutOpenWebsiteTooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        FLucideIcons.globe,
        size: 16,
        color: context.theme.colors.mutedForeground,
      ),
      onPressed: () => _open(context),
    );
  }
}

/// Skeleton tile list untuk section Sponsor/Tim saat loading. Ukuran
/// meniru [_ContributorTile]/[_SponsorTile]: avatar 40 + 2 baris teks.
class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.tileCount});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(width: 96, height: 16),
          const Gap(4),
          for (var i = 0; i < tileCount; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.circle(size: 40),
                  const Gap(10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone(width: 140, height: 14),
                        Gap(4),
                        Bone(width: 220, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AboutLinkBlock extends StatelessWidget {
  const _AboutLinkBlock({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPress,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
        const Gap(8),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onPress,
          prefix: const Icon(FLucideIcons.externalLink, size: 14),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
