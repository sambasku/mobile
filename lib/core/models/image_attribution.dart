/// Label provider foto stock (Media Explorer / atribusi gambar kata).
String shareProviderLabel(String id) => switch (id) {
      'pixabay' => 'Pixabay',
      'openverse' => 'Openverse',
      'unsplash' => 'Unsplash',
      // Legacy atribusi gambar kata / share lama
      'pexels' => 'Pexels',
      'wikimedia' => 'Wikimedia',
      _ => id,
    };

/// Sumber asli Openverse: `flickr` → `Flickr`.
String shareSourceLabel(String source) => source.isEmpty
    ? source
    : '${source[0].toUpperCase()}${source.substring(1)}';

/// Unsplash API Guidelines: semua link balik ke Unsplash wajib ber-UTM.
const _unsplashUtm = {'utm_source': 'sambasku', 'utm_medium': 'referral'};

final unsplashHomeUri = Uri.https('unsplash.com', '/', _unsplashUtm);

Uri unsplashProfileUri(String username) =>
    Uri.https('unsplash.com', '/@$username', _unsplashUtm);

/// Link Unsplash tanpa UTM (mis. data lama) diberi UTM; host lain apa adanya.
Uri withUnsplashUtm(Uri uri) {
  final host = uri.host.toLowerCase();
  final isUnsplash = host == 'unsplash.com' || host.endsWith('.unsplash.com');
  if (!isUnsplash || uri.queryParameters.containsKey('utm_source')) return uri;
  return uri.replace(queryParameters: {...uri.queryParameters, ..._unsplashUtm});
}

/// Kredit foto stock (API `word_images.attribution`, docs/api/01).
/// Upload kamera/galeri tidak punya atribusi.
class ImageAttribution {
  const ImageAttribution({
    required this.name,
    required this.provider,
    this.url,
    this.license,
    this.licenseUrl,
    this.source,
  });

  final String name;

  /// `unsplash` | `pixabay` | `openverse` | …
  final String provider;

  /// Halaman pembuat / foto asli (https).
  final String? url;

  /// CC (Openverse), mis. `CC BY 2.0`.
  final String? license;
  final String? licenseUrl;

  /// Openverse: sumber asli, mis. `flickr`.
  final String? source;

  /// Respons detail kata; null kalau bentuknya tidak dikenali.
  static ImageAttribution? fromJson(Object? json) {
    if (json is! Map) return null;
    String? str(String key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final name = str('name');
    if (name == null) return null;
    return ImageAttribution(
      name: name,
      provider: str('provider') ?? '',
      url: str('url'),
      license: str('license'),
      licenseUrl: str('license_url'),
      source: str('source'),
    );
  }

  /// Body `images[].attribution`. API menolak URL non-https, jadi yang bukan
  /// https dibuang (kredit tetap tampil tanpa link) daripada submit gagal.
  Map<String, dynamic> toJson() {
    String? https(String? u) =>
        u != null && u.startsWith('https://') ? u : null;
    return {
      'name': name,
      'url': ?https(url),
      'license': ?license,
      'license_url': ?https(licenseUrl),
      'source': ?source,
    };
  }
}
