import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/network/failover/api_host_resolver.dart';
import '../../../../core/theme/f_colors_x.dart';

/// Tile "Server" di halaman Profil: user memilih host API (Cloudflare /
/// Deno Deploy / Render) + uji ping sebelum pindah, lalu menguncinya.
///
/// Preseden pola: `api_host_inspector.dart` (dev tool) dan `appearance_tiles.dart`
/// (fungsi FTileMixin yang dimakan FTileGroup halaman Profil).
FTileMixin apiHostTile(BuildContext context, ApiHostResolver resolver) {
  return FTile(
    prefix: const Icon(FLucideIcons.server, size: 18),
    title: const Text('Server'),
    suffix: ListenableBuilder(
      listenable: resolver,
      builder: (_, _) => _ActiveHostLabel(resolver: resolver),
    ),
    onPress: resolver.hasFallbacks ? () => _openSheet(context, resolver) : null,
  );
}

/// Ringkasan host aktif di sisi kanan tile.
class _ActiveHostLabel extends StatelessWidget {
  const _ActiveHostLabel({required this.resolver});

  final ApiHostResolver resolver;

  @override
  Widget build(BuildContext context) {
    final forced = resolver.forcedTierIndex;
    if (forced == null) {
      return Text(
        'Otomatis',
        style: TextStyle(
          fontSize: 13,
          color: context.theme.colors.mutedForeground,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          apiTierLabelForHost(resolver.tiers[forced].host),
          style: TextStyle(
            fontSize: 13,
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(4),
        Icon(FLucideIcons.lock, size: 12, color: context.theme.colors.primary),
      ],
    );
  }
}

void _openSheet(BuildContext context, ApiHostResolver resolver) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ApiHostSheet(resolver: resolver),
  );
}

class _ApiHostSheet extends StatefulWidget {
  const _ApiHostSheet({required this.resolver});

  final ApiHostResolver resolver;

  @override
  State<_ApiHostSheet> createState() => _ApiHostSheetState();
}

/// Hasil ping satu tier, siap ditampilkan dengan ikon + warna status.
class _ProbeOutcome {
  const _ProbeOutcome({required this.ok, required this.label});

  /// true = server balas 200. false = timeout / non-200 / error jaringan.
  final bool ok;
  final String label;
}

class _ApiHostSheetState extends State<_ApiHostSheet> {
  final Map<String, _ProbeOutcome> _probeResults = {};
  bool _probing = false;
  CancelToken? _probeToken;

  @override
  void dispose() {
    _probeToken?.cancel();
    super.dispose();
  }

  /// Ping `GET /api/v1/ping` tiap tier. Tanpa auth, tanpa DB, balas `data.host`
  /// yang membuktikan tier mana yang melayani. Timeout 8 s (`kHealthProbeTimeout`)
  /// supaya tap beruntun tidak menumpuk koneksi native (ANR ColorOS).
  Future<void> _probeAll() async {
    _probeToken?.cancel();
    _probeToken = CancelToken();
    final token = _probeToken!;
    setState(() {
      _probing = true;
      _probeResults.clear();
    });
    final dio = Dio(
      BaseOptions(
        connectTimeout: kHealthProbeTimeout,
        receiveTimeout: kHealthProbeTimeout,
        sendTimeout: kHealthProbeTimeout,
      ),
    );
    try {
      for (final tier in widget.resolver.tiers) {
        if (!mounted || token.isCancelled) return;
        final started = DateTime.now();
        _ProbeOutcome outcome;
        try {
          final res = await dio.get<void>(
            '${tier.host}/api/v1/ping',
            cancelToken: token,
            options: Options(validateStatus: (_) => true),
          );
          final ms = DateTime.now().difference(started).inMilliseconds;
          outcome = res.statusCode == 200
              ? _ProbeOutcome(ok: true, label: '${ms}ms')
              : _ProbeOutcome(ok: false, label: 'HTTP ${res.statusCode}');
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) return;
          final ms = DateTime.now().difference(started).inMilliseconds;
          final timedOut =
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout;
          outcome = _ProbeOutcome(
            ok: false,
            label: timedOut ? 'timeout ${ms}ms' : 'gagal ${ms}ms',
          );
        } catch (_) {
          final ms = DateTime.now().difference(started).inMilliseconds;
          outcome = _ProbeOutcome(ok: false, label: 'gagal ${ms}ms');
        }
        if (!mounted || token.isCancelled) return;
        setState(() => _probeResults[tier.host] = outcome);
      }
    } finally {
      dio.close(force: true);
      if (mounted) setState(() => _probing = false);
    }
  }

  Future<void> _select(int? index) async {
    await widget.resolver.setForcedTier(index);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final resolver = widget.resolver;
    final tiers = resolver.tiers;
    final forced = resolver.forcedTierIndex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(FLucideIcons.server, size: 20),
                const Gap(8),
                const Expanded(
                  child: Text(
                    'Pilih Server',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                FButton(
                  size: FButtonSizeVariant.sm,
                  onPress: _probing ? null : _probeAll,
                  child: Text(_probing ? 'Ping...' : 'Ping'),
                ),
              ],
            ),
            const Gap(8),
            Text(
              'Pilih server yang paling cepat. Hasil uji hanya menunjukkan '
              'kondisi saat ini - Render tidur setelah ~15 menit menganggur '
              'dan bisa butuh sampai 60 detik untuk bangun.',
              style: TextStyle(
                fontSize: 11,
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            FTileGroup(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                FTile(
                  title: const Text('Otomatis'),
                  subtitle: const Text(
                    'Pakai Cloudflare, pindah sendiri kalau gagal (disarankan)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: forced == null,
                  suffix: forced == null
                      ? const Icon(FLucideIcons.check)
                      : null,
                  onPress: () => _select(null),
                ),
                for (var i = 0; i < tiers.length; i++)
                  FTile(
                    title: Text(apiTierLabelForHost(tiers[i].host)),
                    subtitle: _ProbeStatus(
                      host: tiers[i].host,
                      outcome: _probeResults[tiers[i].host],
                      probing: _probing,
                    ),
                    selected: forced == i,
                    suffix: forced == i ? const Icon(FLucideIcons.check) : null,
                    onPress: () => _select(i),
                  ),
              ],
            ),
            const Gap(12),
            if (forced != null)
              Text(
                'Server terkunci: pindah otomatis ke server lain dimatikan '
                'sampai kamu pilih "Otomatis" lagi.',
                style: TextStyle(
                  fontSize: 11,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget subtitle yang menampilkan status ping dengan ikon + warna.
class _ProbeStatus extends StatelessWidget {
  const _ProbeStatus({
    required this.host,
    required this.outcome,
    required this.probing,
  });

  final String host;
  final _ProbeOutcome? outcome;
  final bool probing;

  @override
  Widget build(BuildContext context) {
    if (probing) {
      // Saat ping berjalan, tampilkan spinner di sebelah host.
      return Row(
        children: [
          Text(
            host,
            style: TextStyle(
              fontSize: 13,
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Gap(4),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    if (outcome == null) {
      // Belum diuji — tampilkan host saja.
      return Text(
        host,
        style: TextStyle(
          fontSize: 13,
          color: context.theme.colors.mutedForeground,
        ),
      );
    }

    // Sudah ada hasil — pisahkan host (teks biasa) dari hasil ping (ikon+warna).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          host,
          style: TextStyle(
            fontSize: 13,
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(2),
        Row(
          children: [
            Icon(
              outcome!.ok ? FLucideIcons.checkCircle : FLucideIcons.alertCircle,
              size: 12,
              color: outcome!.ok
                  ? context.theme.colors.success
                  : context.theme.colors.destructive,
            ),
            const Gap(4),
            Text(
              outcome!.label,
              style: TextStyle(
                fontSize: 11,
                color: outcome!.ok
                    ? context.theme.colors.success
                    : context.theme.colors.destructive,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
