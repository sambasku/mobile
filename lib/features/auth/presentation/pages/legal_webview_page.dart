import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'legal_webview_policy.dart';

/// WebView dokumen legal publik (Syarat dan Ketentuan).
/// JS dimatikan + navigasi dibatasi same-host; host lain dibuka
/// eksternal via url_launcher (#75).
class LegalWebViewPage extends StatefulWidget {
  const LegalWebViewPage({required this.url, required this.title, super.key});

  final String url;
  final String title;

  @override
  State<LegalWebViewPage> createState() => _LegalWebViewPageState();
}

class _LegalWebViewPageState extends State<LegalWebViewPage> {
  late final WebViewController _controller;
  late final Uri _initialUri;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _initialUri = Uri.parse(widget.url);
    _controller = WebViewController()
      // Dokumen statis - JS tidak diperlukan (#75).
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final target = Uri.parse(request.url);
            if (shouldAllowInAppNavigation(_initialUri, target)) {
              return NavigationDecision.navigate;
            }
            _openExternal(request.url);
            return NavigationDecision.prevent;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(_initialUri);
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    // Best-effort: gagal buka eksternal → diam (tetap preventNavigation).
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(widget.title),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/register'),
          ),
        ],
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: FCircularProgress()),
        ],
      ),
    );
  }
}
