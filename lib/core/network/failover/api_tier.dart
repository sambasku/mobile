import 'package:flutter/foundation.dart';

/// Satu tier API: host plus anggaran waktunya sendiri.
///
/// Host cold-start (kalau ada) butuh timeout receive lebih panjang dari
/// default 15 detik - lihat `isColdStartHost` di `api_host_resolver.dart`.
@immutable
class ApiTier {
  const ApiTier({
    required this.index,
    required this.host,
    required this.timeout,
  });

  /// 0-based; ditampilkan sebagai "Tier ${index + 1}" di dev tool.
  final int index;
  final String host;
  final Duration timeout;

  /// Nomor tier yang dibaca manusia.
  int get number => index + 1;

  /// Label ringkas untuk dev tool dan log: "Tier 2 - cloudflare.sambasku.com".
  String get label => 'Tier $number - ${Uri.parse(host).host}';

  @override
  bool operator ==(Object other) =>
      other is ApiTier &&
      other.index == index &&
      other.host == host &&
      other.timeout == timeout;

  @override
  int get hashCode => Object.hash(index, host, timeout);

  @override
  String toString() => 'ApiTier($number, $host, ${timeout.inSeconds}s)';
}
