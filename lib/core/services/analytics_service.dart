import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../flavors.dart';

/// Nama event kanonik .
abstract final class AnalyticsEvents {
  static const screenView = 'screen_view';
  static const searchSubmit = 'search_submit';
  static const wotdTap = 'wotd_tap';
  static const wordOpen = 'word_open';
  static const audioPlay = 'audio_play';
  static const contributeStart = 'contribute_start';
  static const contributeSubmit = 'contribute_submit';
  static const contributeSuccess = 'contribute_success';
  static const contributeFail = 'contribute_fail';
  static const exploreCategoryTap = 'explore_category_tap';
  static const mapOpen = 'map_open';
  static const mapFallbackShown = 'map_fallback_shown';
  static const wilayahKecDetailOpen = 'wilayah_kec_detail_open';
  static const wilayahDesaDetailOpen = 'wilayah_desa_detail_open';
  static const wilayahDesaSelect = 'wilayah_desa_select';
  static const wilayahKecSelect = 'wilayah_kec_select';
  static const voteCast = 'vote_cast';
  static const voteDeckView = 'vote_deck_view';
  static const voteDeckSwipe = 'vote_deck_swipe';
  static const bookmarkToggle = 'bookmark_toggle';
  static const shareStart = 'share_start';
  static const shareComplete = 'share_complete';
  static const authLoginSuccess = 'auth_login_success';
  static const authLoginFail = 'auth_login_fail';
  static const authRegisterSuccess = 'auth_register_success';
  static const authLogout = 'auth_logout';
  static const searchMissTap = 'search_miss_tap';
  static const searchMissListOpen = 'search_miss_list_open';
  /// #193: pengguna ganti chip kategori feed beranda.
  static const feedFilter = 'feed_filter';
  /// Pengguna ganti chip Desa/Wisata/Usaha/Acara di sheet Wilayah.
  static const wilayahSheetTab = 'wilayah_sheet_tab';
  static const commentSubmit = 'comment_submit';

  /// Bukan `notification_open`: nama itu reserved Firebase (otomatis dari FCM).
  static const inboxOpen = 'inbox_open';
  static const achievementsView = 'achievements_view';
  static const achievementBadgeView = 'achievement_badge_view';
  static const notificationItemTap = 'notification_item_tap';

  /// Shortcut profil "Izinkan notifikasi".
  /// `result`: granted | denied | settings | dismissed. `source`: profile.
  static const notificationAllow = 'notification_allow';
  static const suggestEditSubmit = 'suggest_edit_submit';
  static const audioRecordStart = 'audio_record_start';
  static const audioRecordSubmit = 'audio_record_submit';
  static const reportWordSubmit = 'report_word_submit';
  static const imageViolenceReveal = 'image_violence_reveal';
  static const reportBugSubmit = 'report_bug_submit';
static const onboardingComplete = 'onboarding_complete';
static const themeChange = 'theme_change';
static const localeChosen = 'locale_chosen';
  static const reviewApprove = 'review_approve';
  static const reviewReject = 'review_reject';
  static const reviewCorrect = 'review_correct';
  static const reviewSkip = 'review_skip';
  static const verifierApplySubmit = 'verifier_apply_submit';
  static const poiOpen = 'poi_open';
  static const cuisineOpen = 'cuisine_open';

  /// Detail usaha / acara / pantun dibuka.
  static const usahaOpen = 'usaha_open';
  static const eventOpen = 'event_open';
  static const pantunOpen = 'pantun_open';

  /// Daftar usulan milik user dibuka (bukan form kontribusi).
  static const usulanWisataOpen = 'usulan_wisata_open';
  static const usulanUsahaOpen = 'usulan_usaha_open';
  static const usulanKulinerOpen = 'usulan_kuliner_open';
  static const usulanAcaraOpen = 'usulan_acara_open';

  /// Form kontribusi dibuka (sebelum kirim).
  static const wisataContributeOpen = 'wisata_contribute_open';
  static const usahaContributeOpen = 'usaha_contribute_open';
  static const kulinerContributeOpen = 'kuliner_contribute_open';
  static const acaraContributeOpen = 'acara_contribute_open';
  static const pantunComposeOpen = 'pantun_compose_open';

  /// Form kontribusi berhasil dikirim ke API.
  static const wisataContributeSubmit = 'wisata_contribute_submit';
  static const usahaContributeSubmit = 'usaha_contribute_submit';
  static const kulinerContributeSubmit = 'kuliner_contribute_submit';
  static const acaraContributeSubmit = 'acara_contribute_submit';
  static const pantunSubmit = 'pantun_submit';

  /// Aksi domain usaha / wisata / pantun di luar open+submit form.
  static const usahaClaimsOpen = 'usaha_claims_open';
  static const usahaClaimSubmit = 'usaha_claim_submit';
  static const usahaSayaOpen = 'usaha_saya_open';
  static const usahaReportSubmit = 'usaha_report_submit';
  static const placePhotosOpen = 'place_photos_open';
  static const pantunReportSubmit = 'pantun_report_submit';
  static const pantunDelete = 'pantun_delete';
}

/// Abstraksi Firebase Analytics. Page/notifier memanggil ini, bukan
/// `FirebaseAnalytics` langsung.
class AnalyticsService {
  AnalyticsService._({FirebaseAnalytics? analytics}) : _injected = analytics;

  static AnalyticsService? _instance;

  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  /// Untuk tes: inject mock / reset singleton.
  @visibleForTesting
  static void debugReset([AnalyticsService? service]) {
    _instance = service;
  }

  /// Injected (tes) atau di-resolve lazy saat [init] - jangan sentuh
  /// `FirebaseAnalytics.instance` di konstruktor: widget test tidak
  /// menginisialisasi Firebase, sementara router/logout/contribute
  /// sudah memanggil [instance] sebelum `main()` sempat `init()`.
  final FirebaseAnalytics? _injected;
  FirebaseAnalytics? _resolved;
  bool _ready = false;

  FirebaseAnalytics get _analytics =>
      _injected ?? (_resolved ??= FirebaseAnalytics.instance);

  /// Panggil sekali setelah `Firebase.initializeApp()`.
  Future<void> init() async {
    if (_ready) return;
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setUserProperty(
        name: 'app_flavor',
        value: F.appFlavor.name,
      );
      _ready = true;
    } catch (e, st) {
      debugPrint('AnalyticsService.init failed: $e\n$st');
    }
  }

  Future<void> log(String name, {Map<String, Object>? params}) async {
    if (!_ready) return;
    try {
      final cleaned = params == null
          ? null
          : <String, Object>{
              for (final e in params.entries)
                if (e.value.toString().isNotEmpty) e.key: e.value,
            };
      await _analytics.logEvent(name: name, parameters: cleaned);
    } catch (e, st) {
      debugPrint('AnalyticsService.log($name) failed: $e\n$st');
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_ready) return;
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e, st) {
      debugPrint('AnalyticsService.logScreenView failed: $e\n$st');
    }
  }

  Future<void> logSearchSubmit({
    required int queryLen,
    required String searchIn,
    required bool hasResults,
  }) => log(
    AnalyticsEvents.searchSubmit,
    params: {
      'query_len': queryLen,
      'search_in': searchIn,
      'has_results': hasResults ? 1 : 0,
    },
  );

  Future<void> logWordOpen({required String wordId, required String source}) =>
      log(
        AnalyticsEvents.wordOpen,
        params: {'word_id': wordId, 'source': source},
      );

  Future<void> logContributeSubmit({required bool guest}) =>
      log(AnalyticsEvents.contributeSubmit, params: {'guest': guest ? 1 : 0});

  Future<void> logContributeSuccess({required bool guest, String? wordId}) =>
      log(
        AnalyticsEvents.contributeSuccess,
        params: {'guest': guest ? 1 : 0, 'word_id': ?wordId},
      );

  Future<void> logContributeFail({required bool guest, String? errorCode}) =>
      log(
        AnalyticsEvents.contributeFail,
        params: {'guest': guest ? 1 : 0, 'error_code': ?errorCode},
      );

  Future<void> logExploreCategoryTap({
    required String categoryId,
    required bool comingSoon,
  }) => log(
    AnalyticsEvents.exploreCategoryTap,
    params: {'category_id': categoryId, 'coming_soon': comingSoon ? 1 : 0},
  );

  Future<void> logWilayahKecDetailOpen({required String slug}) =>
      log(AnalyticsEvents.wilayahKecDetailOpen, params: {'slug': slug});

  Future<void> logWilayahDesaDetailOpen({required String slug}) =>
      log(AnalyticsEvents.wilayahDesaDetailOpen, params: {'slug': slug});

  Future<void> logWilayahDesaSelect({required String desaId}) =>
      log(AnalyticsEvents.wilayahDesaSelect, params: {'desa_id': desaId});

  Future<void> logWilayahKecSelect({required String kecId}) =>
      log(AnalyticsEvents.wilayahKecSelect, params: {'kec_id': kecId});

  Future<void> logWilayahSheetTab({required String tab}) =>
      log(AnalyticsEvents.wilayahSheetTab, params: {'tab': tab});

  Future<void> logMapOpen({required String entry, required String mode}) =>
      log(AnalyticsEvents.mapOpen, params: {'entry': entry, 'mode': mode});

  Future<void> logMapFallback({required String reason}) =>
      log(AnalyticsEvents.mapFallbackShown, params: {'reason': reason});

  Future<void> logVoteCast({
    required String targetType,
    required int direction,
  }) => log(
    AnalyticsEvents.voteCast,
    params: {'target_type': targetType, 'direction': direction},
  );

  Future<void> logBookmarkToggle({
    required String wordId,
    required String action,
  }) => log(
    AnalyticsEvents.bookmarkToggle,
    params: {'word_id': wordId, 'action': action},
  );

  Future<void> logAuthSuccess({
    required String event,
    required String method,
  }) => log(event, params: {'method': method});

  /// Pin peta / kartu detail Place dibuka. `entry`: list | map | pin.
  Future<void> logPoiOpen({
    required String slug,
    required String category,
    required String entry,
  }) => log(
    AnalyticsEvents.poiOpen,
    params: {'slug': slug, 'category': category, 'entry': entry},
  );

  /// Detail cuisine dibuka dari kartu daftar. Param identitas: slug.
  Future<void> logCuisineOpen({required String slug}) =>
      log(AnalyticsEvents.cuisineOpen, params: {'slug': slug});

  Future<void> logUsahaOpen({required String slug}) =>
      log(AnalyticsEvents.usahaOpen, params: {'slug': slug});

  Future<void> logEventOpen({required String slug}) =>
      log(AnalyticsEvents.eventOpen, params: {'slug': slug});

  Future<void> logPantunOpen({required String pantunId}) =>
      log(AnalyticsEvents.pantunOpen, params: {'pantun_id': pantunId});

  Future<void> logUsulanWisataOpen() => log(AnalyticsEvents.usulanWisataOpen);

  Future<void> logUsulanUsahaOpen() => log(AnalyticsEvents.usulanUsahaOpen);

  Future<void> logUsulanKulinerOpen() => log(AnalyticsEvents.usulanKulinerOpen);

  Future<void> logUsulanAcaraOpen() => log(AnalyticsEvents.usulanAcaraOpen);

  /// `mode`: create | edit | photo.
  Future<void> logWisataContributeOpen({required String mode}) => log(
    AnalyticsEvents.wisataContributeOpen,
    params: {'mode': mode},
  );

  Future<void> logUsahaContributeOpen() =>
      log(AnalyticsEvents.usahaContributeOpen);

  /// `mode`: cuisine | place | link.
  Future<void> logKulinerContributeOpen({required String mode}) => log(
    AnalyticsEvents.kulinerContributeOpen,
    params: {'mode': mode},
  );

  Future<void> logAcaraContributeOpen() =>
      log(AnalyticsEvents.acaraContributeOpen);

  Future<void> logPantunComposeOpen({required bool isReply}) => log(
    AnalyticsEvents.pantunComposeOpen,
    params: {'is_reply': isReply ? 1 : 0},
  );

  /// `mode`: create | edit | photo.
  Future<void> logWisataContributeSubmit({required String mode}) => log(
    AnalyticsEvents.wisataContributeSubmit,
    params: {'mode': mode},
  );

  Future<void> logUsahaContributeSubmit() =>
      log(AnalyticsEvents.usahaContributeSubmit);

  /// `mode`: cuisine | place | link.
  Future<void> logKulinerContributeSubmit({required String mode}) => log(
    AnalyticsEvents.kulinerContributeSubmit,
    params: {'mode': mode},
  );

  Future<void> logAcaraContributeSubmit() =>
      log(AnalyticsEvents.acaraContributeSubmit);

  Future<void> logPantunSubmit({required bool isReply}) => log(
    AnalyticsEvents.pantunSubmit,
    params: {'is_reply': isReply ? 1 : 0},
  );

  Future<void> logUsahaClaimsOpen() => log(AnalyticsEvents.usahaClaimsOpen);

  Future<void> logUsahaClaimSubmit({required String slug}) =>
      log(AnalyticsEvents.usahaClaimSubmit, params: {'slug': slug});

  Future<void> logUsahaSayaOpen() => log(AnalyticsEvents.usahaSayaOpen);

  Future<void> logUsahaReportSubmit({required String slug}) =>
      log(AnalyticsEvents.usahaReportSubmit, params: {'slug': slug});

  Future<void> logPlacePhotosOpen({required String slug}) =>
      log(AnalyticsEvents.placePhotosOpen, params: {'slug': slug});

  /// `target_type`: pantun | pantun_reply.
  Future<void> logPantunReportSubmit({required String targetType}) => log(
    AnalyticsEvents.pantunReportSubmit,
    params: {'target_type': targetType},
  );

  Future<void> logPantunDelete({required bool isReply}) => log(
    AnalyticsEvents.pantunDelete,
    params: {'is_reply': isReply ? 1 : 0},
  );

  /// Sub-tab pencapaian dibuka. `tab`: badge | border | pencapaian.
  Future<void> logAchievementsView({required String tab}) =>
      log(AnalyticsEvents.achievementsView, params: {'tab': tab});

  /// Satu lencana dilihat/diketuk. Param identitas: code.
  Future<void> logAchievementBadgeView({required String code}) =>
      log(AnalyticsEvents.achievementBadgeView, params: {'code': code});
}
