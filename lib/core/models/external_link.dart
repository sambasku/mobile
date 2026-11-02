/// UTM referal untuk semua link eksternal (rule external-link-utm).
///
/// Tujuan: web target (FB/IG/website penyelenggara) tahu trafik datang dari
/// SambasKu (muncul di insight mereka sebagai referral). Preseden pola ini:
/// kredit Unsplash (`image_attribution.dart`, `utm_source=sambasku` - syarat
/// API Unsplash, TIDAK digabung dengan helper ini).
///
/// Aturan: sisip on-the-fly saat membuka tautan; URL di DB tetap bersih;
/// tidak menimpa `utm_source` yang sudah ada; link ke domain sendiri tidak
/// diberi UTM.
library;

import 'package:url_launcher/url_launcher.dart';

const utmSource = 'sambasku.com';
const utmMedium = 'referral';

/// Domain SambasKu sendiri + sub-domainnya: tidak diberi UTM.
const ownHosts = <String>{
  'sambasku.com',
  'www.sambasku.com',
  'api.sambasku.com',
  'render.sambasku.com',
  'sambasku-staging.iamutaki.com',
  'sambasku-web-staging.ibnuul.workers.dev',
};

/// True kalau host adalah domain SambasKu sendiri (atau sub-domainnya).
bool isOwnHost(String host) {
  final lower = host.toLowerCase();
  return ownHosts.contains(lower) ||
      lower.endsWith('.sambasku.com') ||
      lower.endsWith('.iamutaki.com');
}

/// Tambah `utm_source=sambasku.com&utm_medium=referral` ke URI https eksternal.
///
/// Input bukan https / punya `utm_source` sendiri / domain sendiri: apa
/// adanya. Query string dan hash yang sudah ada tetap utuh.
Uri withSambaskuUtm(Uri uri) {
  if (uri.scheme.toLowerCase() != 'https') return uri;
  if (isOwnHost(uri.host)) return uri;
  if (uri.queryParameters.containsKey('utm_source')) return uri;
  return uri.replace(
    queryParameters: {
      ...uri.queryParameters,
      'utm_source': utmSource,
      'utm_medium': utmMedium,
    },
  );
}

/// Satu-satunya jalan keluar ke web eksternal dari app.
///
/// Menambah UTM referal otomatis (link sumber event, kredit foto, tautan
/// pengumuman, link diskusi, dan lain-lain). Link internal app (deeplink)
/// tidak boleh lewat sini - pakai `context.push`/`go_router`.
Future<bool> launchExternalUrl(Uri uri) async {
  if (uri.scheme.toLowerCase() != 'https') return false;
  try {
    return await launchUrl(
      withSambaskuUtm(uri),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    return false;
  }
}
