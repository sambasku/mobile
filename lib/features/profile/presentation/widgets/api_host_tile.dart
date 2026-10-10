import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/network/failover/api_host_resolver.dart';

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
    onPress: resolver.hasFallbacks
        ? () => _openSheet(context, resolver)
        : null,
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

class _ApiHostSheetState extends State<_ApiHostSheet> {
  final Map<String, String> _probeResults = {};
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
        String result;
        try {
          final res = await dio.get<void>(
            '${tier.host}/api/v1/ping',
            cancelToken: token,
            options: Options(validateStatus: (_) => true),
          );
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = res.statusCode == 200 ? 'OK ${ms}ms' : 'HTTP ${res.statusCode}';
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) return;
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'Gagal ${ms}ms';
        } catch (_) {
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'Gagal ${ms}ms';
        }
        if (!mounted || token.isCancelled) return;
        setState(() => _probeResults[tier.host] = result);
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
                  child: Text(_probing ? 'Menguji...' : 'Uji semua'),
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
                  ),
                  selected: forced == null,
                  suffix: forced == null ? const Icon(FLucideIcons.check) : null,
                  onPress: () => _select(null),
                ),
                for (var i = 0; i < tiers.length; i++)
                  FTile(
                    title: Text(apiTierLabelForHost(tiers[i].host)),
                    subtitle: Text(
                      _probeResults[tiers[i].host] == null
                          ? tiers[i].host
                          : '${tiers[i].host}\n${_probeResults[tiers[i].host]}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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