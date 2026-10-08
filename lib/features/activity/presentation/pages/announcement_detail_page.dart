import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/feed_activity_item.dart';

/// Halaman detail pengumuman (#102): payload beku dari baris feed.
/// Action (opsional): host SambasKu = deep link in-app (route dikenal),
/// host lain = browser eksternal (#124).
class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final FeedAnnouncement announcement;

  /// Snapshot tujuan tombol: host + label in-app/eksternal (#124).
  /// Host saja - full URL sengaja tidak ditampilkan.
  String get _hostSnapshot {
    final url = Uri.tryParse(announcement.actionUrl ?? '');
    final host = url?.host.toLowerCase() ?? '';
    if (host.isEmpty) return '';
    return isInAppDeepLink ? '$host · buka di aplikasi' : host;
  }

  /// Host SambasKu sendiri = kemungkinan besar ada route in-app.
  bool get isInAppDeepLink {
    final url = Uri.tryParse(announcement.actionUrl ?? '');
    if (url == null || !url.isScheme('https')) return false;
    final host = url.host.toLowerCase();
    return host == 'sambasku.com' || host == 'www.sambasku.com';
  }

  Future<void> _openAction(BuildContext context) async {
    final url = Uri.tryParse(announcement.actionUrl ?? '');
    if (url == null || !url.isScheme('https')) return;
    if (isInAppDeepLink) {
      // Deep link in-app: route GoRouter (path+query), tanpa keluar app.
      GoRouter.of(
        context,
      ).push(url.path + (url.hasQuery ? '?${url.query}' : ''));
      return;
    }
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FButton(
                      // #124: pembeda visual - in-app (chain) vs eksternal (globe).
                      onPress: () => _openAction(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInAppDeepLink
                                ? FLucideIcons.link
                                : FLucideIcons.globe,
                            size: 16,
                          ),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              (announcement.actionLabel ?? '').trim().isNotEmpty
                                  ? announcement.actionLabel!.trim()
                                  : 'Buka tautan',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // #124: snapshot host (bukan full URL) - transparan ke mana
                    // tombol menuju tanpa memenuhi layar.
                    const Gap(6),
                    Text(
                      _hostSnapshot,
                      textAlign: TextAlign.center,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
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
          _AnnouncementBody(
            body: announcement.body,
            bodyType: announcement.bodyType,
          ),
        ],
      ),
    );
  }
}

/// Loader isi WebView: html = string HTML dibungkus shell; webview =
/// URL https -> loadRequest, selain itu dianggap string HTML.
extension _WebViewControllerBody on WebViewController {
  Future<void> _loadBody(String body, AnnouncementBodyType type) async {
    if (type == AnnouncementBodyType.webview) {
      final uri = Uri.tryParse(body.trim());
      if (uri != null && uri.isScheme('https')) {
        await loadRequest(uri);
        return;
      }
    }
    await loadHtmlString(
      '<!doctype html><html><head><meta name="viewport" '
      'content="width=device-width, initial-scale=1">'
      '<style>body{font-family:-apple-system,sans-serif;'
      'font-size:16px;line-height:1.5;margin:8px;'
      'color:#1f2328;background:transparent}'
      'a{color:#1668dc}</style></head><body>$body</body></html>',
    );
  }
}

/// Body pengumuman per tipe eksplisit dari API (#124):
/// - plain -> Text biasa
/// - md -> flutter_markdown (native, ikut tema terang/gelap)
/// - html -> flutter_html_style? belum - dirender via WebView inline JS off
/// - webview -> isi (URL/HTML) dimuat via WebView
class _AnnouncementBody extends StatelessWidget {
  const _AnnouncementBody({required this.body, required this.bodyType});

  final String body;
  final AnnouncementBodyType bodyType;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return switch (bodyType) {
      AnnouncementBodyType.plain => Text(
        body,
        style: theme.typography.md.copyWith(height: 1.5),
      ),
      AnnouncementBodyType.md => MarkdownBody(
        data: body,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: theme.typography.md.copyWith(height: 1.5),
          h1: theme.typography.xl2.copyWith(fontWeight: FontWeight.w700),
          h2: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
          h3: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
          listBullet: theme.typography.md,
        ),
      ),
      AnnouncementBodyType.html || AnnouncementBodyType.webview => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 320,
          child: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.disabled)
              ..setNavigationDelegate(
                NavigationDelegate(
                  // Navigasi dalam WebView diblok; link -> browser.
                  onNavigationRequest: (req) {
                    if (req.url.startsWith('about:')) {
                      return NavigationDecision.navigate;
                    }
                    unawaited(
                      launchUrl(
                        Uri.parse(req.url),
                        mode: LaunchMode.externalApplication,
                      ).catchError((_) => false),
                    );
                    return NavigationDecision.prevent;
                  },
                ),
              )
              // html: bungkus string HTML. webview: body = URL -> loadRequest
              // (JS tetap off, navigasi tetap ke browser), selain itu HTML.
              .._loadBody(body, bodyType),
          ),
        ),
      ),
    };
  }
}
