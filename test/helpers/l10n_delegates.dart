import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Delegates l10n (app + Forui) untuk `MaterialApp` di widget test yang
/// memakai `AppLocalizations.of(context)`.
const appLocalizationDelegates = [
  ...AppLocalizations.localizationsDelegates,
  ...FLocalizations.localizationsDelegates,
];

/// Locale app: default test `en_US` tidak didukung ARB, jadi paksa `id`.
const appTestLocale = Locale('id');

/// Supported locales ARB (pasangkan dengan [appLocalizationDelegates]).
List<Locale> get appTestSupportedLocales => AppLocalizations.supportedLocales;
