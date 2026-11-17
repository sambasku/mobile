import 'dart:async';

import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/models/external_link.dart';
import '../../features/auth/presentation/pages/legal_webview_policy.dart';
import '../../l10n/app_localizations.dart';

/// Bottomsheet pratinjau tautan markdown: WebView (JS off + cookie dibersihkan),
/// URL asli yang bisa disalin, dan opsi buka di browser eksternal.
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Text(
                  l10n.markdownLinkSheetTitle,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SelectableText(
                  urlText,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => _copyUrl(l10n),
                        child: Text(l10n.notificationCopyLink),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: FButton(
                        onPress: _openExternal,
                        child: Text(l10n.markdownLinkOpenBrowser),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebViewWidget(controller: _controller),
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
