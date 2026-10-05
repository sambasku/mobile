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
  static const commentSubmit = 'comment_submit';

  /// Bukan `notification_open`: nama itu reserved Firebase (otomatis dari FCM).
  static const inboxOpen = 'inbox_open';
  static const notificationItemTap = 'notification_item_tap';
  static const suggestEditSubmit = 'suggest_edit_submit';
  static const audioRecordStart = 'audio_record_start';
  static const audioRecordSubmit = 'audio_record_submit';
  static const reportWordSubmit = 'report_word_submit';
  static const imageViolenceReveal = 'image_violence_reveal';
  static const reportBugSubmit = 'report_bug_submit';
  static const onboardingComplete = 'onboarding_complete';
  static const themeChange = 'theme_change';
  static const reviewApprove = 'review_approve';
  static const reviewReject = 'review_reject';
  static const reviewCorrect = 'review_correct';
  static const reviewSkip = 'review_skip';
  static const verifierApplySubmit = 'verifier_apply_submit';
  static const poiOpen = 'poi_open';
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
}
