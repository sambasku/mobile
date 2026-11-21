import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/models/external_link.dart';
import '../../features/auth/presentation/pages/legal_webview_policy.dart';
import '../../l10n/app_localizations.dart';
import 'small_button.dart';

/// Bottomsheet pratinjau tautan markdown: WebView (JS off + cookie dibersihkan),
/// URL satu baris (ellipsis) + info full URL, salin & buka browser di kanan.
Future<void> showMarkdownLinkSheet(
  BuildContext context, {
  required Uri uri,
}) async {
  if (!uri.isScheme('https')) return;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _MarkdownLinkSheet(uri: uri),
  );
}

class _MarkdownLinkSheet extends StatefulWidget {
  const _MarkdownLinkSheet({required this.uri});

  final Uri uri;

  @override
  State<_MarkdownLinkSheet> createState() => _MarkdownLinkSheetState();
}

class _MarkdownLinkSheetState extends State<_MarkdownLinkSheet> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.uri;
    _controller = WebViewController()
      // JS off: kurangi permukaan curi cookie / XSS di pratinjau in-app.
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final target = Uri.tryParse(request.url);
            if (target == null) return NavigationDecision.prevent;
            if (shouldAllowInAppNavigation(initial, target)) {
              return NavigationDecision.navigate;
            }
            // Host lain / skema lain: buka eksternal, jangan lanjut di sheet.
            unawaited(launchExternalUrl(target));
            return NavigationDecision.prevent;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      );
    unawaited(_prepareAndLoad(initial));
  }

  Future<void> _prepareAndLoad(Uri initial) async {
    try {
      await WebViewCookieManager().clearCookies();
    } catch (_) {
      // Best-effort: platform tanpa cookie manager tidak boleh blok load.
    }
    if (!mounted) return;
    await _controller.loadRequest(initial);
  }

  Future<void> _copyUrl(AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: widget.uri.toString()));
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(l10n.notificationLinkCopied),
    );
  }

  Future<void> _openExternal() async {
    await launchExternalUrl(widget.uri);
  }

  Future<void> _showFullUrlSheet(AppLocalizations l10n) async {
    final urlText = widget.uri.toString();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.paddingOf(sheetContext).bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FAlert(
                  title: Text(l10n.markdownLinkFullUrlTitle),
                  subtitle: SelectableText(urlText),
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SmallButton(
                    label: l10n.notificationCopyLink,
                    prefixIcon: FLucideIcons.copy,
                    onPress: () {
                      unawaited(_copyUrl(l10n));
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final height = MediaQuery.sizeOf(context).height * 0.82;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final urlText = widget.uri.toString();

    return SizedBox(
      height: height,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Text(
                  l10n.markdownLinkSheetTitle,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Gap(4),
              // Satu baris: URL terpotong + info full | salin + buka di kanan.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                urlText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                          FButton.icon(
                            variant: FButtonVariant.ghost,
                            size: .sm,
                            onPress: () => unawaited(_showFullUrlSheet(l10n)),
                            child: Icon(
                              FLucideIcons.info,
                              size: 16,
                              semanticLabel: l10n.markdownLinkShowFullSemantics,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      size: .sm,
                      onPress: () => unawaited(_copyUrl(l10n)),
                      child: Icon(
                        FLucideIcons.copy,
                        size: 16,
                        semanticLabel: l10n.markdownLinkCopySemantics,
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      size: .sm,
                      onPress: () => unawaited(_openExternal()),
                      child: Icon(
                        FLucideIcons.externalLink,
                        size: 16,
                        semanticLabel: l10n.markdownLinkOpenBrowserSemantics,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(4),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // EagerRecognizer: modal bottom sheet default mencuri
                    // VerticalDrag untuk dismiss, jadi WebView tak bisa scroll.
                    WebViewWidget(
                      controller: _controller,
                      gestureRecognizers: const {
                        Factory<OneSequenceGestureRecognizer>(
                          EagerGestureRecognizer.new,
                        ),
                      },
                    ),
                    if (_loading)
                      const Center(child: FCircularProgress()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
