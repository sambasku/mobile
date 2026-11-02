import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/analytics_service.dart';
import 'app_locale.dart';
import 'locale_prefs.dart';

part 'locale_controller.g.dart';

/// Bahasa UI aktif. Persist di [LocalePrefs] (`sk_locale` +
/// `sk_locale_chosen`), seed [LocalePrefs.locale] dibaca sebelum runApp
/// supaya frame pertama tidak flash bahasa default.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  AppLocale build() => LocalePrefs.locale;

  Future<void> set(AppLocale next, {String source = 'settings'}) async {
    if (next == state) return;
    state = next;
    await LocalePrefs.set(next);
    await AnalyticsService.instance.log(
      AnalyticsEvents.localeChosen,
      params: {'locale': next.code, 'source': source},
    );
  }
}
