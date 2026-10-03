import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../core/network/failover/api_host_resolver.dart';
import '../../../core/network/failover/api_tier.dart';
import '../dev_tool_inspector.dart';

class ApiHostInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF16A34A);

  @override
  String get description => 'Paksa tier API + status circuit breaker';

  @override
  IconData get icon => FLucideIcons.server;

  @override
  String get name => 'API Host';

  @override
  Widget buildPage(BuildContext context) => const _ApiHostPage();
}

class _ApiHostPage extends StatefulWidget {
  const _ApiHostPage();

  @override
  State<_ApiHostPage> createState() => _ApiHostPageState();
}

class _ApiHostPageState extends State<_ApiHostPage> {
  final _resolver = ApiHostResolver.instance;

  /// Ticker 1 detik: hitung-mundur pin berjalan tanpa notifikasi dari resolver,
  /// karena kedaluwarsa pin memang dihitung murni saat dibaca (tanpa timer).
  Timer? _ticker;

  /// host → hasil ping terakhir.
  final Map<String, String> _probeResults = {};
  bool _probing = false;
  CancelToken? _probeToken;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _resolver.pinRemaining == null) return;
      setState(() {});
    });
    _resolver.addListener(_onResolverChanged);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _probeToken?.cancel();
    _resolver.removeListener(_onResolverChanged);
    super.dispose();
  }

  void _onResolverChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _setMode(int? index) async {
    _probeToken?.cancel();
    await _resolver.setForcedTier(index);
  }

  Future<void> _probeAll() async {
    _probeToken?.cancel();
    _probeToken = CancelToken();
    final token = _probeToken!;
    setState(() {
      _probing = true;
      _probeResults.clear();
    });
    // Dio bersih + timeout PENDEK: jangan pakai 75s milik tier 3. Ping
    // beruntun dengan timeout itu menumpuk HttpClient native dan memicu
    // ANR di ColorOS saat host di-tap berulang.
    final dio = Dio(
      BaseOptions(
        connectTimeout: kHealthProbeTimeout,
        receiveTimeout: kHealthProbeTimeout,
        sendTimeout: kHealthProbeTimeout,
      ),
    );
    try {
      for (final tier in _resolver.tiers) {
        if (!mounted || token.isCancelled) return;
        final started = DateTime.now();
        String result;
        try {
          final res = await dio.get<void>(
            '${tier.host}/health',
            cancelToken: token,
            options: Options(validateStatus: (_) => true),
          );
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'HTTP ${res.statusCode} - ${ms}ms';
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) return;
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'GAGAL setelah ${ms}ms';
        } catch (_) {
          final ms = DateTime.now().difference(started).inMilliseconds;
          result = 'GAGAL setelah ${ms}ms';
        }
        if (!mounted || token.isCancelled) return;
        setState(() => _probeResults[tier.host] = result);
      }
    } finally {
      dio.close(force: true);
      if (mounted) setState(() => _probing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiers = _resolver.tiers;
    if (!_resolver.hasFallbacks) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Flavor ini hanya punya satu host, jadi tidak ada tier cadangan '
            'dan circuit breaker diam.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final active = _resolver.activeTier;
    final remaining = _resolver.pinRemaining;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(
          active: active,
          remaining: remaining,
          forced: _resolver.forcedTierIndex != null,
        ),
        const Gap(16),
        Row(
          children: [
            FButton(
              size: FButtonSizeVariant.xs,
              onPress: remaining == null ? null : _resolver.resetToPrimary,
              child: const Text('Lepas pin'),
            ),
            const Gap(8),
            FButton(
              size: FButtonSizeVariant.xs,
              onPress: _probing ? null : _probeAll,
              child: Text(_probing ? 'Menguji...' : 'Uji semua host'),
            ),
          ],
        ),
        const Gap(8),
        const Text(
          'Ping memakai timeout 8 detik. Render yang tidur mungkin gagal '
          'di tap pertama - itu normal, instance sudah mulai bangun.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const Gap(20),
        FTileGroup(
          label: const Text('Mode'),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _modeTile(
              label: 'Otomatis',
              subtitle: 'Mulai di tier 1, pindah hanya saat gagal',
              index: null,
            ),
            for (final tier in tiers)
              _modeTile(
                label: 'Tier ${tier.number}',
                subtitle: tier.host,
                index: tier.index,
              ),
          ],
        ),
        const Gap(20),
        FTileGroup(
          label: const Text('Tier'),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final tier in tiers)
              _tierTile(
                tier: tier,
                isActive: tier.index == active.index,
                probeResult: _probeResults[tier.host],
              ),
          ],
        ),
      ],
    );
  }

  FTile _modeTile({
    required String label,
    required String subtitle,
    required int? index,
  }) {
    final selected = _resolver.forcedTierIndex == index;
    return FTile(
      title: Text(label),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: selected,
      suffix: selected ? const Icon(FLucideIcons.check) : null,
      onPress: () => _setMode(index),
    );
  }

  FTile _tierTile({
    required ApiTier tier,
    required bool isActive,
    String? probeResult,
  }) {
    return FTile(
      prefix: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.green : Colors.grey.shade400,
        ),
      ),
      title: Text('Tier ${tier.number} - timeout ${tier.timeout.inSeconds}s'),
      subtitle: Text(
        probeResult == null ? tier.host : '${tier.host}\n$probeResult',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.active,
    required this.remaining,
    required this.forced,
  });

  final ApiTier active;
  final Duration? remaining;
  final bool forced;

  @override
  Widget build(BuildContext context) {
    final onPrimary = active.index == 0;
    final left = remaining;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (onPrimary ? Colors.green : Colors.orange).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (onPrimary ? Colors.green : Colors.orange).withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktif: ${active.label}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const Gap(4),
          Text(
            active.host,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Gap(4),
          Text(
            'Timeout ${active.timeout.inSeconds}s',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Gap(8),
          Text(
            forced
                ? 'Dipaksa dari dev tool - breaker diabaikan.'
                : left == null
                ? 'Tidak ada pin aktif.'
                : 'Pin tersisa ${left.inMinutes}m ${left.inSeconds % 60}s, '
                      'lalu tier 1 dicoba lagi.',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
