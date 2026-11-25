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
import '../../../../shared/widgets/public_browse_list_divider.dart';
import '../../data/datasources/about_api_datasource.dart';
import '../../../user_profile/user_profile_router.dart';
import '../providers/about_api_providers.dart';
import 'oss_licenses_page.dart';

/// Halaman About: identitas app + blok info & fitur (murni info app).
/// Daftar Sponsor/Tim pindah ke halaman Komunitas (Phase 5).
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
                title: l10n.aboutSourceTitle,
                body: l10n.aboutSourceBody,
                actionLabel: l10n.aboutSourceAction,
                onPress: () => launchExternalUrl(AboutPage.githubUri),
              ),
              const Gap(16),
              _AboutLinkBlock(
                title: l10n.aboutOssTitle,
                body: l10n.aboutOssBody,
                actionLabel: l10n.aboutOssAction,
                icon: FLucideIcons.bookOpen,
                onPress: () => context.push(OssLicensesPage.path),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Halaman Sponsor ATAU Tim (tanpa tab atas).
/// Dipilih lewat [showTeam]: true = Tim Kami (+ chip), false = Sponsor & Mitra.
class SponsorshipTeamPage extends StatelessWidget {
  const SponsorshipTeamPage({super.key, this.showTeam = false});

  final bool showTeam;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(showTeam ? l10n.aboutTabTeam : l10n.aboutSponsorshipTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/about'),
          ),
        ],
      ),
      child: showTeam ? const _TeamTab() : const _SponsorsTab(),
    );
  }
}

class _SponsorsTab extends ConsumerWidget {
  const _SponsorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(aboutSponsorshipsProvider);
        await ref.read(aboutSponsorshipsProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          _AboutBlock(title: l10n.aboutSupportTitle, body: l10n.aboutSupportBody),
          const Gap(16),
          const _SponsorsSection(),
        ],
      ),
    );
  }
}

enum _TeamChip { tim, verifikator, kontributor }

/// Tab Tim: chip filter Tim | Verifikator | Kontributor (pola chip aktivitas).
/// Data Tim = users.is_team lewat GET /about/team.
class _TeamTab extends ConsumerStatefulWidget {
  const _TeamTab();

  @override
  ConsumerState<_TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends ConsumerState<_TeamTab> {
  var _chip = _TeamChip.tim;

  Future<void> _refresh() async {
    switch (_chip) {
      case _TeamChip.tim:
        ref.invalidate(aboutTeamProvider);
        await ref.read(aboutTeamProvider.future);
      case _TeamChip.verifikator:
        ref.invalidate(aboutVerifiersProvider);
        await ref.read(aboutVerifiersProvider.future);
      case _TeamChip.kontributor:
        ref.invalidate(aboutContributorsProvider);
        await ref.read(aboutContributorsProvider.future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = switch (_chip) {
      _TeamChip.tim => (l10n.aboutTabTeam, l10n.aboutTeamSectionBody),
      _TeamChip.verifikator => (
        l10n.aboutVerifiersTitle,
        l10n.aboutVerifiersSectionBody,
      ),
      _TeamChip.kontributor => (
        l10n.aboutContributorsTitle,
        l10n.aboutContributorsSectionBody,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        _TeamFilterChips(
          selected: _chip,
          onSelect: (c) => setState(() => _chip = c),
        ),
        const Gap(8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              children: [
                _AboutBlock(title: title, body: body),
                const Gap(12),
                switch (_chip) {
                  _TeamChip.tim => const _TeamCoreSection(),
                  _TeamChip.verifikator => const _VerifiersSection(),
                  _TeamChip.kontributor => const _ContributorsFlatSection(),
                },
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamFilterChips extends StatelessWidget {
  const _TeamFilterChips({required this.selected, required this.onSelect});

  final _TeamChip selected;
  final ValueChanged<_TeamChip> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      _TeamChip.tim: l10n.aboutChipTeam,
      _TeamChip.verifikator: l10n.aboutChipVerifiers,
      _TeamChip.kontributor: l10n.aboutChipContributors,
    };
    // Scaffold childPad sudah inset horizontal - jangan dobel 12.
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const Gap(6),
        itemBuilder: (context, i) {
          final chip = labels.keys.elementAt(i);
          final isSelected = chip == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(chip),
            child: FBadge(
              variant: isSelected
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(labels[chip]!),
            ),
          );
        },
      ),
    );
  }
}

/// Inti Tim: users.is_team (avatar + team_as + note).
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
    if (members == null || members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Text(
          l10n.aboutTeamChipEmpty,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < members.length; i++) ...[
          _TeamMemberTile(member: members[i]),
          if (i < members.length - 1) ...[
            const Gap(8),
            const PublicBrowseListDivider(),
            const Gap(8),
          ],
        ],
      ],
    );
  }
}

/// Warga: nama saja + paginasi server.
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
    if (state == null || state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Text(
          l10n.aboutTeamChipEmpty,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in state.items)
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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item.displayName,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ),
          ),
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

/// Verifikator: satu baris kompak (avatar, nama, chevron) + paginasi server.
class _VerifiersSection extends ConsumerWidget {
  const _VerifiersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(aboutVerifiersProvider);
    final state = async.value;
    if (async.isLoading && state == null) {
      return const _SectionSkeleton(tileCount: 3);
    }
    if (state == null || state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Text(
          l10n.aboutTeamChipEmpty,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < state.items.length; i++) ...[
          _CompactVerifierTile(verifier: state.items[i]),
          if (i < state.items.length - 1) ...[
            const Gap(6),
            const PublicBrowseListDivider(),
            const Gap(6),
          ],
        ],
        if (state.hasMore) ...[
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: state.loadingMore
                ? null
                : () => ref.read(aboutVerifiersProvider.notifier).loadMore(),
            prefix: state.loadingMore ? const FCircularProgress() : null,
            child: Text(l10n.aboutContributorsLoadMore),
          ),
        ],
      ],
    );
  }
}

class _CompactVerifierTile extends StatelessWidget {
  const _CompactVerifierTile({required this.verifier});

  final AboutVerifier verifier;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => UserProfileRouter.open(
          context,
          verifier.username,
          displayName: verifier.displayName,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: verifier.avatarUrl == null
                      ? const ImagePlaceholder256()
                      : CachedNetworkImageWithFallback(
                          imageUrl: verifier.avatarUrl!,
                          fallback: const ImagePlaceholder256(),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  verifier.displayName,
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
    );
  }
}


class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({required this.member});

  final AboutTeamMember member;

  @override
  Widget build(BuildContext context) {
    final role = member.teamAs?.trim();
    final noteLines = member.teamNoteLines;
    return _PersonAvatarTile(
      username: member.username,
      displayName: member.displayName,
      avatarUrl: member.avatarUrl,
      roleLine: (role != null && role.isNotEmpty) ? role : null,
      noteLines: noteLines,
    );
  }
}

class _PersonAvatarTile extends StatelessWidget {
  const _PersonAvatarTile({
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.roleLine,
    this.noteLines = const [],
  });

  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? roleLine;
  final List<String> noteLines;

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
              if (roleLine case final role? when role.isNotEmpty) ...[
                const Gap(2),
                Text(
                  role,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
              if (noteLines.isNotEmpty)
                for (final line in noteLines) ...[
                  const Gap(2),
                  Text(
                    line,
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
    this.icon = FLucideIcons.externalLink,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPress;
  final IconData icon;

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
          prefix: Icon(icon, size: 14),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
