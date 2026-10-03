import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/image_placeholder_256.dart';
import '../../data/datasources/contributors_remote_datasource.dart';
import '../../data/datasources/sponsors_remote_datasource.dart';
import '../providers/contributors_providers.dart';
import '../providers/sponsors_providers.dart';

/// Halaman About: identitas app, lalu tab Tentang dan Tim Kami.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Uri organizationUri = Uri.parse(
    'https://github.com/sambasku#organisasi',
  );

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

          return Column(
            children: [
              const Gap(4),
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
              const Gap(12),
              const Expanded(child: _AboutTabs()),
            ],
          );
        },
      ),
    );
  }
}

class _AboutTabs extends StatelessWidget {
  const _AboutTabs();

  @override
  Widget build(BuildContext context) {
    return FTabs(
      expands: true,
      children: const [
        FTabEntry.entry(label: Text('Tentang'), child: _AboutTab()),
        FTabEntry.entry(label: Text('Tim Kami'), child: _TeamTab()),
      ],
    );
  }
}

class _AboutTab extends ConsumerWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        const _SponsorsSection(),
        const Gap(16),
        _AboutLinkBlock(
          title: 'Kode Sumber & Lisensi',
          body:
              'SambasKu adalah proyek open source. Kode sumbernya '
              'tersedia di GitHub dan dirilis di bawah lisensi GPLv3. '
              'Kamu bebas mempelajari, memodifikasi, dan mendistribusikan '
              'kodenya sesuai ketentuan lisensi.',
          actionLabel: 'Lihat di GitHub',
          onPress: () => launchUrl(
            AboutPage.organizationUri,
            mode: LaunchMode.externalApplication,
          ),
        ),
        const Gap(16),
        _AboutLinkBlock(
          title: 'Organisasi di GitHub',
          body:
              'Identitas organisasi, cara ikut serta, sponsor, dan '
              'saluran komunitas.',
          actionLabel: 'Buka di GitHub',
          onPress: () => launchUrl(
            AboutPage.organizationUri,
            mode: LaunchMode.externalApplication,
          ),
        ),
        const Gap(16),
        const _AboutBlock(
          title: 'Apa itu SambasKu?',
          body:
              'Kamus digital Sambas-Indonesia. Cari arti, baca contoh, '
              'usulkan kata, bookmark, dan bagikan kartu. Entri tayang '
              'setelah verifikasi.',
        ),
        const Gap(16),
        const _AboutBlock(
          title: 'Cari kosakata',
          body:
              'Ketik lemma atau terjemahan. Setiap entri menampilkan '
              'kelas kata, definisi, contoh kalimat, dan variasi '
              'penulisan.',
        ),
        const Gap(16),
        const _AboutBlock(
          title: 'Simpan',
          body:
              'Bookmark kata dari halaman detail, lalu buka lagi '
              'dari Profil.',
        ),
        const Gap(16),
        const _AboutBlock(
          title: 'Usulkan',
          body:
              'Warga mengusulkan kata baru atau perbaikan. Usulan '
              'langsung tayang dengan label Menunggu pengecekan. '
              'Kontributor bisa mengajukan diri jadi verifikator.',
        ),
        const Gap(16),
        const _AboutBlock(
          title: 'Bagikan kartu',
          body:
              'Dari detail kata, atur gaya dan latar (foto, video, '
              'atau warna polos), lalu Simpan ke galeri atau Bagikan '
              'ke aplikasi lain.',
        ),
        const Gap(16),
      ],
    );
  }
}

class _TeamTab extends ConsumerWidget {
  const _TeamTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: const [
        _ContributorsSection(),
        Gap(16),
        _AboutBlock(
          title: 'Bersama warga Sambas',
          body:
              'Kamus ini dirawat orang-orang yang mengusulkan kata, '
              'memeriksa entri, dan merekam pelafalan.',
        ),
        Gap(16),
        _AboutBlock(
          title: 'Pengusul',
          body:
              'Mengirim kata baru atau perbaikan. Entri tayang setelah '
              'verifikasi.',
        ),
        Gap(16),
        _AboutBlock(
          title: 'Verifikator',
          body: 'Memeriksa usulan sebelum masuk kamus.',
        ),
        Gap(16),
        _AboutBlock(
          title: 'Kontributor pelafalan',
          body: 'Merekam cara mengucapkan kata agar bisa didengar.',
        ),
      ],
    );
  }
}

/// Daftar kontributor langsung project dari CDN. Null/kosong/gagal fetch =
/// section hilang (soft-fail, halaman About tetap utuh).
class _ContributorsSection extends ConsumerWidget {
  const _ContributorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributors = ref.watch(contributorsProvider).value;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contributor.avatarUrl case final avatar?)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
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
  }
}

/// Daftar sponsor dari CDN. Null/kosong/gagal fetch = section hilang
/// (soft-fail, halaman About tetap utuh).
class _SponsorsSection extends ConsumerWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsors = ref.watch(sponsorsProvider).value;
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
                  'data. Pencantuman nama keduanya gratis.',
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 6),
              child: Icon(
                Icons.info_outline,
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
    final subtitle = [
      ?sponsor.description,
      sponsor.note,
    ].join(' - ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sponsor.logoUrl case final logo?)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
              const Gap(2),
              Text(
                subtitle,
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
