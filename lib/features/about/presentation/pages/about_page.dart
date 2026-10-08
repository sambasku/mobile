import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/image_placeholder_256.dart';
import '../../data/datasources/contributors_remote_datasource.dart';
import '../../data/datasources/sponsors_remote_datasource.dart';
import '../../../user_profile/user_profile_router.dart';
import '../providers/contributors_providers.dart';
import '../providers/sponsors_providers.dart';

/// Halaman About: identitas app + blok info & fitur. Data Sponsor/Mitra
/// dan Tim Kami pindah ke [SponsorshipTeamPage] supaya tidak duplikat.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  /// Profil organisasi sekaligus daftar repo publik (kode sumber).
  static final Uri githubUri = Uri.parse('https://github.com/sambasku');

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tentang'),
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
                'Kamus Digital Sambas-Indonesia',
                textAlign: TextAlign.center,
                style: theme.typography.xs.copyWith(
                  height: 1.2,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(2),
              Text(
                'Versi $versionLabel',
                textAlign: TextAlign.center,
                style: theme.typography.xs.copyWith(
                  height: 1.2,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              const _AboutBlock(
                title: 'Apa itu SambasKu?',
                body:
                    'Kamus digital Melayu Sambas-Indonesia yang dirawat '
                    'bersama warga. Kamu bisa mencari arti kata, membaca '
                    'contoh kalimat, menyimpan kata, mengusulkan kata baru, '
                    'dan membagikan kartu kata. Usulan dari akun yang sudah '
                    'masuk langsung tayang dengan label Menunggu pengecekan, '
                    'lalu diperiksa verifikator.',
              ),
              const Gap(16),
              _AboutLinkBlock(
                title: 'Sponsor & Tim Kami',
                body:
                    'Para pendukung operasional dan orang-orang yang '
                    'merawat kamus ini.',
                actionLabel: 'Lihat Sponsor & Tim Kami',
                onPress: () => context.push('/about/sponsorship'),
              ),
              const Gap(16),
              _AboutLinkBlock(
                title: 'Kode Sumber & Organisasi',
                body:
                    'SambasKu adalah proyek open source. Kode sumbernya '
                    'dirilis dengan lisensi GPLv3, jadi kamu bebas '
                    'mempelajari, mengubah, dan membagikannya sesuai '
                    'ketentuan lisensi. Konten kamus dan datanya dirilis '
                    'dengan lisensi CC BY-SA 4.0, jadi wajib mencantumkan '
                    'sumber dan membagikan hasilnya dengan lisensi yang '
                    'sama. Di GitHub juga ada profil organisasi, cara '
                    'ikut serta, info sponsor, dan saluran komunitas.',
                actionLabel: 'Buka di GitHub',
                onPress: () => launchUrl(
                  AboutPage.githubUri,
                  mode: LaunchMode.externalApplication,
                ),
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
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Sponsor & Tim Kami'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/about'),
          ),
        ],
      ),
      child: FTabs(
        expands: true,
        children: const [
          FTabEntry.entry(
            label: Text('Sponsor & Mitra'),
            child: _SponsorsTab(),
          ),
          FTabEntry.entry(label: Text('Tim Kami'), child: _TeamTab()),
        ],
      ),
    );
  }
}

class _SponsorsTab extends StatelessWidget {
  const _SponsorsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: const [
        _AboutBlock(
          title: 'Ingin ikut mendukung?',
          body:
              'Dukungan bisa lewat GitHub Sponsors atau Saweria. Detail '
              'kerja sama ada di profil organisasi kami di GitHub.',
        ),
        Gap(16),
        _SponsorsSection(),
      ],
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: const [
        _AboutBlock(
          title: 'Bersama warga Sambas',
          body:
              'Kamus ini dirawat orang-orang yang mengusulkan kata, '
              'memeriksa entri, dan merekam pelafalan.',
        ),
        Gap(16),
        _AboutBlock(
          title: 'Kontributor',
          body:
              'Mengirim kata baru atau perbaikan, dan merekam cara '
              'mengucapkan kata agar bisa didengar. Entri tayang setelah '
              'verifikasi.',
        ),
        Gap(16),
        _AboutBlock(
          title: 'Verifikator',
          body: 'Memeriksa usulan sebelum masuk kamus.',
        ),
        Gap(16),
        _ContributorsSection(),
      ],
    );
  }
}

/// Daftar kontributor dari CDN. Loading = skeleton (anti layout shift).
/// Null/kosong/gagal fetch = section hilang (soft-fail, halaman tetap utuh).
class _ContributorsSection extends ConsumerWidget {
  const _ContributorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contributorsProvider);
    final contributors = async.value;
    // Loading tanpa data: skeleton. Error tapi sempat punya data (keepAlive
    // tidak aktif, jarang): tetap soft-fail.
    if (async.isLoading && contributors == null) {
      return const _SectionSkeleton(tileCount: 4);
    }
    if (contributors == null || contributors.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tim Kami',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        for (final contributor in contributors) ...[
          _ContributorTile(contributor: contributor),
          const Gap(8),
        ],
      ],
    );
  }
}

class _ContributorTile extends StatelessWidget {
  const _ContributorTile({required this.contributor});

  final ContributorEntry contributor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final tile = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contributor.avatarUrl case final avatar?)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CachedNetworkImageWithFallback(
                  imageUrl: avatar,
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
                contributor.name,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              if (contributor.roles.isNotEmpty)
                Text(
                  contributor.roles.join(', '),
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              const Gap(2),
              Text(
                contributor.note,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // #100: punya akun SambasKu -> tap buka profil publik in-app.
    // Tanpa username -> tile polos (tidak interaktif).
    final username = contributor.sambaskuUsername;
    if (username == null) return tile;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => UserProfileRouter.open(
          context,
          username,
          displayName: contributor.name,
        ),
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

/// Daftar sponsor dari CDN. Loading = skeleton (anti layout shift).
/// Null/kosong/gagal fetch = section hilang (soft-fail, halaman tetap utuh).
class _SponsorsSection extends ConsumerWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sponsorsProvider);
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
              'Sponsor & Mitra',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.foreground,
              ),
            ),
            const Gap(4),
            Tooltip(
              message:
                  'Sponsor: pemberi dana atau barang untuk biaya '
                  'operasional (domain, server, honorarium). Mitra: rekan '
                  'kerja sama yang berkontribusi dana, tenaga, materi, atau '
                  'data. Nama semua pendukung kami cantumkan sebagai '
                  'apresiasi atas dukungannya.',
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

  final SponsorEntry sponsor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final subtitleParts = [
      ?sponsor.description,
      if (sponsor.note.trim().isNotEmpty) sponsor.note,
    ];
    final subtitle = subtitleParts.join(' - ');

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
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              if (subtitleParts.isNotEmpty) ...[
                const Gap(2),
                Text(
                  subtitle,
                  style: theme.typography.sm.copyWith(
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
    final username = sponsor.sambaskuUsername;
    if (username == null) return tile;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => UserProfileRouter.open(
          context,
          username,
          displayName: sponsor.name,
        ),
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
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.sm.copyWith(
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
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.sm.copyWith(
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
