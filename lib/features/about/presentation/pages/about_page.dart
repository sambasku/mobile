import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/brand_logo.dart';

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

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
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
