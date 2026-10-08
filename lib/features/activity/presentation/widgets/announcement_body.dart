import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/feed_activity_item.dart';

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

/// Body pengumuman / notifikasi inbox per tipe eksplisit dari API (#124):
/// - plain -> Text biasa
/// - md -> flutter_markdown (native, ikut tema terang/gelap)
/// - html -> flutter_html_style? belum - dirender via WebView inline JS off
/// - webview -> isi (URL/HTML) dimuat via WebView
class AnnouncementBody extends StatelessWidget {
  const AnnouncementBody({
    super.key,
    required this.body,
    required this.bodyType,
  });

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
