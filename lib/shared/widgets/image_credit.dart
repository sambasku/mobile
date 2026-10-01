import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/image_attribution.dart';

/// Kredit foto stock per provider:
/// - Unsplash/Pixabay: "Foto oleh Nama di Unsplash" (Unsplash ber-UTM).
/// - CC (Openverse): "Foto oleh Nama di Flickr · CC BY 2.0" + link lisensi.
/// [compact] untuk tile sempit: "Nama / Unsplash" atau "Nama · CC BY 2.0".
class ImageCredit extends StatelessWidget {
  const ImageCredit({
    super.key,
    required this.attribution,
    this.color,
    this.fontSize = 13,
    this.compact = false,
  });

  final ImageAttribution attribution;
  final Color? color;
  final double fontSize;
  final bool compact;

  static Uri? _providerHome(String provider) => switch (provider) {
        'unsplash' => unsplashHomeUri,
        'pixabay' => Uri.https('pixabay.com', '/'),
        'pexels' => Uri.https('www.pexels.com', '/'),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.theme.colors.mutedForeground;
    final base = context.theme.typography.sm.copyWith(
      fontSize: fontSize,
      color: c,
    );
    final link = base.copyWith(
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: c,
    );

    Widget part(String value, Uri? uri) {
      final ok = uri != null && uri.isScheme('https');
      final t = Text(
        value,
        style: ok ? link : base,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
      if (!ok) return t;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => launchUrl(
          withUnsplashUtm(uri),
          mode: LaunchMode.externalApplication,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: t),
            const SizedBox(width: 2),
            Icon(FLucideIcons.externalLink, size: fontSize * 0.85, color: c),
          ],
        ),
      );
    }

    final a = attribution;
    final source = a.source;
    final where = source != null
        ? shareSourceLabel(source)
        : shareProviderLabel(a.provider.isEmpty ? 'openverse' : a.provider);
    final license = a.license;
    final nameUrl = a.url;
    final licenseUrl = a.licenseUrl;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!compact) Text('Foto oleh ', style: base),
        part(a.name, nameUrl == null ? null : Uri.tryParse(nameUrl)),
        if (license != null) ...[
          if (!compact) Text(' di $where', style: base),
          Text(' · ', style: base),
          part(license, licenseUrl == null ? null : Uri.tryParse(licenseUrl)),
        ] else ...[
          Text(compact ? ' / ' : ' di ', style: base),
          part(where, source == null ? _providerHome(a.provider) : null),
        ],
      ],
    );
  }
}
