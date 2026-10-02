import 'package:envied/envied.dart';

import '../../flavors.dart';

part 'env.g.dart';

// Env compile-time via envied (Section 8) - host dipilih per flavor,
// TIDAK ADA host hardcode di datasource.
@Envied(path: '.env')
abstract final class Env {
  @EnviedField(varName: 'SAMBASKU_API_HOST_STAGING')
  static const String apiHostStaging = _Env.apiHostStaging;

  @EnviedField(varName: 'SAMBASKU_API_HOST_PRODUCTION', optional: true)
  static const String? apiHostProduction = _Env.apiHostProduction;

  /// Tier cadangan produksi, urut. Dipakai circuit breaker di
  /// `core/network/failover/` - layar tidak tahu ada lebih dari satu host.
  @EnviedField(varName: 'SAMBASKU_API_HOST_FALLBACK_PRODUCTION', optional: true)
  static const String? apiHostFallbackProduction =
      _Env.apiHostFallbackProduction;

  @EnviedField(varName: 'SAMBASKU_API_HOST_FALLBACK2_PRODUCTION', optional: true)
  static const String? apiHostFallback2Production =
      _Env.apiHostFallback2Production;

  /// Web OAuth client ID per env (sama dengan API `GOOGLE_CLIENT_ID`
  /// di wrangler/`.env` yang matching). Dipakai sebagai `serverClientId`.
  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID_STAGING', optional: true)
  static const String? googleWebClientIdStaging = _Env.googleWebClientIdStaging;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID_PRODUCTION', optional: true)
  static const String? googleWebClientIdProduction =
      _Env.googleWebClientIdProduction;

  /// Facebook App ID per env (sama dengan API `FACEBOOK_APP_ID`).
  /// Dipakai untuk menampilkan tombol; App Secret tidak pernah di app.
  @EnviedField(varName: 'FACEBOOK_APP_ID_STAGING', optional: true)
  static const String? facebookAppIdStaging = _Env.facebookAppIdStaging;

  @EnviedField(varName: 'FACEBOOK_APP_ID_PRODUCTION', optional: true)
  static const String? facebookAppIdProduction = _Env.facebookAppIdProduction;

  /// GitHub OAuth App Client ID per env (sama dengan API `GITHUB_CLIENT_ID`).
  /// Secret hanya di backend (tukar code).
  @EnviedField(varName: 'GITHUB_CLIENT_ID_STAGING', optional: true)
  static const String? githubClientIdStaging = _Env.githubClientIdStaging;

  @EnviedField(varName: 'GITHUB_CLIENT_ID_PRODUCTION', optional: true)
  static const String? githubClientIdProduction = _Env.githubClientIdProduction;

  /// Domain web publik (share URL + dokumentasi deep link). Staging vs prod.
  @EnviedField(varName: 'SAMBASKU_WEB_APP_URL_STAGING', optional: true)
  static const String? webAppUrlStaging = _Env.webAppUrlStaging;

  @EnviedField(varName: 'SAMBASKU_WEB_APP_URL_PRODUCTION', optional: true)
  static const String? webAppUrlProduction = _Env.webAppUrlProduction;

  /// Base URL API sesuai flavor aktif (staging build → staging host, dst.).
  static String get apiHost {
    return F.isStaging || apiHostProduction == null
        ? apiHostStaging
        : apiHostProduction!;
  }

  /// Origin situs publik sesuai flavor (untuk caption share / deep link).
  static String? get webAppUrl {
    if (F.isStaging || webAppUrlProduction == null) {
      return _nonEmpty(webAppUrlStaging) ?? 'https://sambasku-web-staging.iamutaki.com';
    }
    return _nonEmpty(webAppUrlProduction) ?? 'https://sambasku.com';
  }

  /// Host cadangan setelah [apiHost], urut tier 2 lalu tier 3.
  ///
  /// Kosong di staging: flavor itu tidak punya cadangan, jadi circuit breaker
  /// tidak punya tujuan pindah dan diam saja.
  static List<String> get apiHostFallbacks {
    if (F.isStaging || apiHostProduction == null) return const [];
    return [
      _nonEmpty(apiHostFallbackProduction),
      _nonEmpty(apiHostFallback2Production),
    ].whereType<String>().toList(growable: false);
  }

  /// Client ID Google mengikuti backend yang sedang dihubungi (`apiHost`).
  static String? get googleWebClientId {
    if (F.isStaging || apiHostProduction == null) {
      return _nonEmpty(googleWebClientIdStaging);
    }
    return _nonEmpty(googleWebClientIdProduction) ??
        _nonEmpty(googleWebClientIdStaging);
  }

  /// App ID Facebook mengikuti backend yang sedang dihubungi (`apiHost`).
  static String? get facebookAppId {
    if (F.isStaging || apiHostProduction == null) {
      return _nonEmpty(facebookAppIdStaging);
    }
    return _nonEmpty(facebookAppIdProduction) ?? _nonEmpty(facebookAppIdStaging);
  }

  /// Client ID GitHub mengikuti backend yang sedang dihubungi (`apiHost`).
  static String? get githubClientId {
    if (F.isStaging || apiHostProduction == null) {
      return _nonEmpty(githubClientIdStaging);
    }
    return _nonEmpty(githubClientIdProduction) ??
        _nonEmpty(githubClientIdStaging);
  }

  /// URL config card dinamis (background WOTD dll) sesuai flavor.
  /// Di-host di repo `data` via jsDelivr, bukan API worker.
  @EnviedField(varName: 'SAMBASKU_CARD_CONFIG_URL_STAGING', optional: true)
  static const String? cardConfigUrlStaging = _Env.cardConfigUrlStaging;

  @EnviedField(varName: 'SAMBASKU_CARD_CONFIG_URL_PRODUCTION', optional: true)
  static const String? cardConfigUrlProduction = _Env.cardConfigUrlProduction;

  static String? get cardConfigUrl {
    if (F.isStaging || cardConfigUrlProduction == null) {
      return _nonEmpty(cardConfigUrlStaging);
    }
    return _nonEmpty(cardConfigUrlProduction) ??
        _nonEmpty(cardConfigUrlStaging);
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

/// URL config card dinamis. Prioritas: env flavor → fallback konstanta.
const kDefaultCardConfigUrl =
    'https://cdn.jsdelivr.net/gh/sambasku/data@main/mobile/home.json';
