import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/feed_activity_item.dart';

/// Normalisasi body webview: console boleh input host tanpa skema
/// (`sambasku.com/x`) - prepend https:// supaya loadRequest jalan,
/// bukan dianggap string HTML lalu blank. String dengan spasi/<>/"
/// atau host tanpa titik bukan URL -> null (render sebagai HTML).
Uri? _normalizeWebviewUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  // Spasi/<>/kutip = bukan URL (mis. string HTML); host tanpa titik juga.
  if (RegExp(r'[\s<>"\"]').hasMatch(s)) return null;
  final withScheme = s.contains('://') ? s : 'https://$s';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || !uri.isScheme('https')) return null;
  return uri.host.contains('.') ? uri : null;
}

/// Loader isi WebView: html = string HTML dibungkus shell; webview =
/// URL https -> loadRequest, selain itu dianggap string HTML.
extension _WebViewControllerBody on WebViewController {
  Future<void> _loadBody(String body, AnnouncementBodyType type) async {
    if (type == AnnouncementBodyType.webview) {
      final uri = _normalizeWebviewUrl(body);
      if (uri != null) {
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
/// - html -> dirender via WebView inline JS off dengan bounded box
/// - webview -> isi (URL/HTML) dimuat via WebView dengan bounded box
class AnnouncementBody extends StatelessWidget {
  const AnnouncementBody({
    super.key,
    required this.body,
    required this.bodyType,
    this.maxHeight,
  });

  final String body;
  final AnnouncementBodyType bodyType;
  final double? maxHeight; // Null = unbounded; set untuk carousel/preview bounded box

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final unbounded = maxHeight == null;
    return switch (bodyType) {
      AnnouncementBodyType.plain => Text(
        body,
        style: theme.typography.md.copyWith(height: 1.5),
      ),
      AnnouncementBodyType.md => unbounded
          ? MarkdownBody(
              data: body,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                p: theme.typography.md.copyWith(height: 1.5),
                h1: theme.typography.xl2.copyWith(fontWeight: FontWeight.w700),
                h2: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
                h3: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
                listBullet: theme.typography.md,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: MarkdownBody(
                  data: body,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                    p: theme.typography.md.copyWith(height: 1.5),
                    h1: theme.typography.xl2.copyWith(fontWeight: FontWeight.w700),
                    h2: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
                    h3: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
                    listBullet: theme.typography.md,
                  ),
                ),
              ),
            ),
      AnnouncementBodyType.html || AnnouncementBodyType.webview =>
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight ?? 320),
            child: _AnnouncementWebView(
              body: body,
              bodyType: bodyType,
            ),
          ),
        ),
    };
  }
}

/// WebView dengan guard navigasi awal: `loadRequest` pertama ikut lewat
/// `onNavigationRequest` di sebagian platform - prevent-all membuat webview
/// blank permanen. URL target pertama diizinkan, sisanya ke browser.
class _AnnouncementWebView extends StatefulWidget {
  const _AnnouncementWebView({required this.body, required this.bodyType});

  final String body;
  final AnnouncementBodyType bodyType;

  @override
  State<_AnnouncementWebView> createState() => _AnnouncementWebViewState();
}

class _AnnouncementWebViewState extends State<_AnnouncementWebView> {
  late final WebViewController _controller;
  Uri? _initialUri;

  @override
  void initState() {
    super.initState();
    _initialUri = widget.bodyType == AnnouncementBodyType.webview
        ? _normalizeWebviewUrl(widget.body)
        : null;
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.disabled)
          ..setNavigationDelegate(
            NavigationDelegate(
              // Navigasi dalam WebView diblok; link -> browser. URL awal
              // (loadRequest/loadHtmlString) diizinkan lewat.
              onNavigationRequest: (req) {
                final initial = _initialUri?.toString();
                if (req.url == 'about:blank' ||
                    (initial != null && req.url == initial)) {
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
          .._loadBody(widget.body, widget.bodyType);
  }

  @override
  Widget build(BuildContext context) =>
      WebViewWidget(controller: _controller);
}

/// Teks preview ringan untuk kartu carousel/list (#134): webview URL valid
/// -> host-nya saja; md/html -> markup dibuang; plain -> apa adanya.
String announcementPreviewText(String body, AnnouncementBodyType bodyType) {
  final uri = bodyType == AnnouncementBodyType.webview
      ? _normalizeWebviewUrl(body)
      : null;
  if (uri != null) return uri.host;
  return bodyType == AnnouncementBodyType.plain
      ? body
      : stripMarkdownHtml(body);
}

/// Preview ringan untuk kartu carousel/list (#134): teks polos maxLines +
/// ellipsis. Satu WebViewController = platform view mahal, dan PageView
/// membangun halaman tetangga - preview harus widget ringan.
class AnnouncementBodyPreview extends StatelessWidget {
  const AnnouncementBodyPreview({
    super.key,
    required this.body,
    required this.bodyType,
    this.maxLines = 3,
  });

  final String body;
  final AnnouncementBodyType bodyType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      announcementPreviewText(body, bodyType),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: theme.typography.md.copyWith(
        height: 1.5,
        color: theme.colors.mutedForeground,
      ),
    );
  }
}

/// Buang markup md/html ringan untuk preview (tanpa parser penuh).
String stripMarkdownHtml(String input) => input
    .replaceAllMapped(
      RegExp(r'```[\s\S]*?```'),
      (_) => '',
    )
    .replaceAll(RegExp(r'`[^`]+`'), '')
    .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'~~([^~]+)~~'), (m) => m[1]!)
    .replaceAll(RegExp(r'#{1,6}\s'), '')
    .replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m[1]!,
    )
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll(RegExp(r'^>+\s?', multiLine: true), '')
    .replaceAll(RegExp(r'\n\s*[-=_*]{3,}\s*\n'), '\n')
    .replaceAll(RegExp(r'\n{2,}'), '\n')
    .trim();