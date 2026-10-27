import 'package:dio/dio.dart';

import '../../i18n/locale_prefs.dart';

/// Sisipkan `Accept-Language` (BCP-47) di semua request supaya backend
/// tinggal membaca header saat i18n API siap - mobile tidak perlu ubah
/// lagi (kontrak MOBILE-I18N: tidak ada endpoint yang memakai locale
/// hari ini; header opt-in, diabaikan backend untuk sekarang).
///
/// Baca seed statis [LocalePrefs.locale], bukan ref/watch: interceptor
/// jalan di luar widget tree; seed di-refresh oleh LocalePrefs.set().
class LocaleHeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = LocalePrefs.locale.bcp47;
    handler.next(options);
  }
}
