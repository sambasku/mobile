import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/env.dart';
import 'api_tier.dart';

/// Timeout tier 1 dan 2 - sama dengan nilai Dio sebelum failover ada.
const kDefaultTierTimeout = Duration(seconds: 15);

/// Timeout tier terakhir. Render paket gratis tidur setelah ~15 menit dan
/// bangun sampai ~60 detik; 15 detik akan selalu habis sebelum ia siap.
const kColdStartTierTimeout = Duration(seconds: 75);

/// Timeout ping `/health` dan warm-up. Cukup untuk memulai boot Render;
/// tidak perlu menunggu instance siap - itu tugas request data (75s).
/// Dipakai DevTool "Uji semua host" supaya tap beruntun tidak menumpuk
/// koneksi native sampai ANR di OEM ColorOS.
const kHealthProbeTimeout = Duration(seconds: 8);

/// Lama satu tier "di-pin" sebelum tier 1 dicoba lagi.
const kTierPinDuration = Duration(minutes: 5);

/// Key preferensi host pilihan USER (bukan dev tool). Dipakai tile "Server"
/// di halaman Profil. `-1` = Otomatis.
const _prefKeyPreferredTier = 'preferredApiTier';

/// Label manusiawi tiap tier untuk UI user. Cocokkan lewat host supaya tahan
/// kalau urutan env berubah; host tak dikenal dikembalikan apa adanya.
String apiTierLabelForHost(String host) {
  final h = Uri.tryParse(host)?.host ?? host;
  if (h.contains('deno')) return 'Deno Deploy';
  if (h.contains('render')) return 'Render';
  if (h.contains('sambasku.com')) return 'Cloudflare';
  if (h.contains('staging')) return 'Staging';
  return h;
}

/// Penentu host API aktif untuk SELURUH aplikasi.
///
/// Singleton tingkat proses, sengaja BUKAN provider Riverpod: `dioProvider`
/// ber-`autoDispose`, jadi state yang menempel di sana akan hilang saat tidak
/// ada yang menonton - padahal pin harus bertahan melewati pembuatan ulang Dio.
///
/// Reaktif, bukan prediktif: aplikasi bertahan di tier 1 sampai ada kegagalan
/// infrastruktur nyata. Tidak ada health check berkala dan tidak ada perpindahan
/// spekulatif.
class ApiHostResolver extends ChangeNotifier {
  ApiHostResolver._();

  static final ApiHostResolver instance = ApiHostResolver._();

  List<ApiTier> _tiers = const [];

  /// Tier yang sedang di-pin setelah kegagalan. Hanya berlaku selama
  /// [_pinnedUntil] belum lewat.
  int _pinnedIndex = 0;
  DateTime? _pinnedUntil;

  /// Override dev tool. null = otomatis.
  int? _forcedIndex;

  /// Menandai jendela pin mana yang warm-up-nya sudah dikirim, supaya ledakan
  /// request gagal tidak melahirkan puluhan ping.
  DateTime? _warmedUpForPin;

  /// Dipanggil sekali per jendela pin untuk membangunkan tier berikutnya lebih
  /// awal. Diisi lapisan jaringan; resolver sendiri tidak melakukan HTTP.
  void Function(ApiTier tier)? onWarmUp;

  /// Batalkan probe/warm-up native yang masih jalan (ganti host di DevTool).
  void Function()? onCancelBackgroundProbes;

  /// Bisa diperkecil di test supaya kedaluwarsa pin benar-benar teruji, bukan
  /// hanya disimulasikan.
  @visibleForTesting
  Duration pinDuration = kTierPinDuration;

  /// Bangun daftar tier dari env. Aman dipanggil berulang (test memanggilnya
  /// tiap kasus).
  void configure({required String primaryHost, required List<String> fallbackHosts}) {
    final hosts = [primaryHost, ...fallbackHosts];
    _tiers = [
      for (var i = 0; i < hosts.length; i++)
        ApiTier(
          index: i,
          host: hosts[i],
          // Tier terakhir menanggung risiko cold start.
          timeout: i == hosts.length - 1 && hosts.length > 1
              ? kColdStartTierTimeout
              : kDefaultTierTimeout,
        ),
    ];
    _pinnedIndex = 0;
    _pinnedUntil = null;
    _warmedUpForPin = null;
    onCancelBackgroundProbes?.call();
    _emitChange();
  }

  /// Konfigurasi dari [Env] - dipakai saat bootstrap aplikasi.
  void configureFromEnv() => configure(
        primaryHost: Env.apiHost,
        fallbackHosts: Env.apiHostFallbacks,
      );

  List<ApiTier> get tiers => _tiers;

  /// false = tidak ada tujuan pindah (mis. flavor staging), interceptor diam.
  bool get hasFallbacks => _tiers.length > 1;

  /// Indeks tier efektif. SENGAJA murni - tidak memutasi apa pun - supaya boleh
  /// dibaca dari `onRequest` tanpa efek samping dan tanpa timer. Pin yang
  /// kedaluwarsa cukup berhenti dihitung.
  int get _effectiveIndex {
    if (_tiers.isEmpty) return 0;
    final forced = _forcedIndex;
    if (forced != null && forced < _tiers.length) return forced;
    final until = _pinnedUntil;
    if (until == null || !DateTime.now().isBefore(until)) return 0;
    return _pinnedIndex;
  }

  ApiTier get activeTier {
    if (_tiers.isEmpty) {
      throw StateError('ApiHostResolver.configure belum dipanggil');
    }
    return _tiers[_effectiveIndex];
  }

  String get activeHost => activeTier.host;

  bool get isOnPrimary => _effectiveIndex == 0;

  int? get forcedTierIndex => _forcedIndex;

  /// Sisa waktu pin, null kalau tidak sedang di-pin.
  Duration? get pinRemaining {
    final until = _pinnedUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    return left.isNegative ? null : left;
  }

  /// Naik SATU tier setelah kegagalan infrastruktur, lalu pin selama
  /// [kTierPinDuration]. Mengembalikan tier baru, atau null kalau sudah di tier
  /// terakhir - tier terakhir bersifat terminal, tidak ada host keempat.
  ApiTier? advanceTier() {
    // DevTool memaksa satu host: jangan cascade di belakang layar
    // (itu yang menumpuk koneksi 75s saat tap pindah-pindah).
    if (_forcedIndex != null) return null;
    final next = _effectiveIndex + 1;
    if (next >= _tiers.length) return null;
    _pinnedIndex = next;
    _pinnedUntil = DateTime.now().add(pinDuration);
    _warmUpTierAfter(next);
    _emitChange();
    return _tiers[next];
  }

  /// Lepas pin dan kembali ke tier 1 sekarang (tombol dev tool).
  void resetToPrimary() {
    if (_pinnedUntil == null) return;
    _pinnedIndex = 0;
    _pinnedUntil = null;
    _warmedUpForPin = null;
    onCancelBackgroundProbes?.call();
    _emitChange();
  }

  /// Bangunkan tier SETELAH yang baru di-pin, sekali per jendela pin.
  ///
  /// Kenapa bukan cron 24/7: menjaga Render melek sepanjang waktu memakan ~730
  /// dari 750 jam gratis per bulan, jadi kuota justru bisa habis tepat saat
  /// cadangan diperlukan. Membangunkan hanya setelah masalah dimulai membuat
  /// tier 3 tetap tidur di hari normal dan tidak memakan jam sama sekali.
  void _warmUpTierAfter(int pinnedIndex) {
    final warmIndex = pinnedIndex + 1;
    if (warmIndex >= _tiers.length) return;
    if (_warmedUpForPin == _pinnedUntil) return;
    _warmedUpForPin = _pinnedUntil;
    onWarmUp?.call(_tiers[warmIndex]);
  }

  // ---- Override dev tool (hanya staging/debug, lihat DevToolOverlay) ----

  Future<void> loadSavedTier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(_prefKeyPreferredTier);
      // Di luar jangkauan tier (mis. konfigurasi berubah) = abaikan, jangan
      // digantung ke host yang tidak ada.
      if (stored == null || stored < 0 || stored >= _tiers.length) return;
      _forcedIndex = stored;
      _emitChange();
    } catch (_) {
      // Preferensi tidak terbaca: tetap otomatis.
    }
  }

  Future<void> setForcedTier(int? index) async {
    if (_forcedIndex == index) return;
    _forcedIndex = index;
    onCancelBackgroundProbes?.call();
    _emitChange();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyPreferredTier, index ?? -1);
    } catch (_) {
      // Gagal menyimpan tidak boleh membatalkan pilihan di sesi ini.
    }
  }

  /// Jangan rebuild widget dari dalam interceptor HTTP (fase layout).
  void _emitChange() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      scheduler.addPostFrameCallback((_) => notifyListeners());
      return;
    }
    notifyListeners();
  }
}
