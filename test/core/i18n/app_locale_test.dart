import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/feature_flags.dart';
import 'package:sambasku_mobile/core/i18n/app_locale.dart';
import 'package:sambasku_mobile/core/i18n/locale_prefs.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppLocale map ke Locale + BCP-47 web', () {
    expect(AppLocale.id.toLocale().languageCode, 'id');
    expect(AppLocale.id.toLocale().countryCode, isNull);
    expect(AppLocale.sbs.toLocale().languageCode, 'id');
    expect(AppLocale.sbs.toLocale().countryCode, 'SBS');

    expect(AppLocale.id.bcp47, 'id');
    expect(AppLocale.sbs.bcp47, 'id-SBS');
    expect(AppLocale.fromWeb('id-SBS'), AppLocale.sbs);
    expect(AppLocale.fromCode('id_SBS'), AppLocale.sbs);
    expect(AppLocale.fromCode('xx'), AppLocale.id);
  });

  test('Localizations id_SBS resolve + fallback ke id', () {
    final sbs = lookupAppLocalizations(AppLocale.sbs.toLocale());
    expect(sbs.localeName, 'id_SBS');
    expect(sbs.onboardingLanguageTitle, isNotEmpty);
    // Key yang belum diterjemahkan jatuh ke template id.
    expect(
      sbs.settingsTitle,
      lookupAppLocalizations(const Locale('id')).settingsTitle,
    );
  });

  test('supportedLocales dari generated cocok registry', () {
    expect(
      AppLocalizations.supportedLocales,
      [for (final l in AppLocale.all) l.toLocale()],
    );
  });

  test('LocalePrefs set menandai chosen', () async {
    await LocalePrefs.reset();
    expect(LocalePrefs.chosen, isFalse);
    await LocalePrefs.set(AppLocale.sbs);
    expect(LocalePrefs.chosen, isTrue);
    // MULTI_LANGUAGE_ENABLED default off: sbs di-clamp ke id.
    // Aktifkan via --dart-define=MULTI_LANGUAGE_ENABLED=true bila mau uji sbs.
    expect(
      LocalePrefs.locale,
      FeatureFlags.multiLanguageEnabled ? AppLocale.sbs : AppLocale.id,
    );
    await LocalePrefs.reset();
    expect(LocalePrefs.locale, AppLocale.id);
  });
}

