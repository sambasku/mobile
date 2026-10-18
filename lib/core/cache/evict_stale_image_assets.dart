import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versi aset gambar yang URL-nya TIDAK berubah saat kontennya diganti
/// (mis. `placeholder.webp` di repo `images`). Naikkan nilai ini setiap kali
/// aset semacam itu diganti isinya; entri cache gambar lama lalu dibuang
/// supaya di-fetch ulang dari CDN.
const _kImageAssetRevision = 1;
const _kPrefsKey = 'image_asset_revision';

/// URL yang byte-nya pernah berubah tanpa ganti nama/path.
const _staleProneUrls = <String>[
  'https://cdn.jsdelivr.net/gh/sambasku/images@main/assets/places/placeholder.webp',
];

/// Buang cache gambar untuk URL di [_staleProneUrls] sekali per revisi.
/// Tanpa ini: `cached_network_image_ce` key cache = URL, jadi byte lama di
/// disk terus dipakai walau CDN sudah di-purge. Gagal di sini tidak fatal.
Future<void> evictStaleImageAssets(SharedPreferences prefs) async {
  try {
    if (prefs.getInt(_kPrefsKey) == _kImageAssetRevision) return;
    for (final url in _staleProneUrls) {
      await DefaultCacheManager().removeFile(url);
    }
    await prefs.setInt(_kPrefsKey, _kImageAssetRevision);
  } catch (e) {
    // ponytail: best-effort. Kalau gagal (IO/cache manager belum siap),
    // gambar lama tetap tampil satu sesi; jalankan lagi di start berikutnya.
    debugPrint('evictStaleImageAssets gagal: $e');
  }
}
