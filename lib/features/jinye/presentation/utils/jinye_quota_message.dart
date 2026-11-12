import 'package:dio/dio.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';

/// Ambil sisa detik kuota dari `Retry-After` atau `data.retry_after`.
int? retryAfterSecondsFromDio(DioException error) {
  final headers = error.response?.headers;
  final header =
      headers?.value('retry-after') ?? headers?.value('Retry-After');
  final data = error.response?.data;
  Object? bodyVal;
  if (data is Map) {
    final nested = data['data'];
    if (nested is Map) bodyVal = nested['retry_after'];
    bodyVal ??= data['retry_after'];
  }
  return int.tryParse('${header ?? bodyVal ?? ''}');
}

/// Pesan kuota create/quote Jinye dengan jam reset lokal bila tersedia.
String jinyeQuotaRateLimitedMessage(
  DioException error,
  AppLocalizations l10n,
) {
  final seconds = retryAfterSecondsFromDio(error);
  if (seconds != null && seconds > 0) {
    final at = DateTime.now().add(Duration(seconds: seconds));
    return l10n.jinyeCreateRateLimitedUntil(formatClockLocal(at));
  }
  final msg = error.response?.data is Map
      ? (error.response!.data as Map)['message']
      : null;
  if (msg is String && msg.trim().isNotEmpty) return msg;
  return l10n.jinyeCreateRateLimited;
}
