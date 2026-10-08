import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/feed_activity_item.dart';

/// Halaman detail pengumuman (#102): payload beku dari baris feed.
/// Action (opsional) membuka link eksternal - host sudah di-whitelist API.
class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final FeedAnnouncement announcement;

  Future<void> _openAction() async {
    final url = Uri.tryParse(announcement.actionUrl ?? '');
    if (url == null || !url.isScheme('https')) return;
    // ponytail: cek host whitelist lokal = upgrade saat admin butuh host
    // dinamis; sekarang sinkron manual dengan announcement.validator.ts API.
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Browser tak tersedia: diam saja, tombol bisa dicoba lagi.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final canOpen =
        !announcement.expired && (announcement.actionUrl ?? '').isNotEmpty;

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Pengumuman'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      childPad: true,
      // CTA di footer: selalu terjangkau walau konten panjang (slot resmi
      // FScaffold.footer). Tanpa action / expired → footer kosong (null).
      footer: canOpen
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FButton(
                  onPress: _openAction,
                  child: Text(
                    (announcement.actionLabel ?? '').trim().isNotEmpty
                        ? announcement.actionLabel!.trim()
                        : 'Buka tautan',
                  ),
                ),
              ),
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (announcement.expired)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FCard.raw(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.clock,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Pengumuman ini sudah berakhir, tapi tetap bisa dibaca.',
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Text(
            announcement.title,
            style: theme.typography.xl2.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const Gap(12),
          Text(
            announcement.body,
            style: theme.typography.md.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
