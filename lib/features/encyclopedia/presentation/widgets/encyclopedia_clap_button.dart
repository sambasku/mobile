import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/encyclopedia_providers.dart';
import '../utils/encyclopedia_auth.dart';

/// Clap artikel ala Medium: tap berulang +1 sampai 50 per user.
class EncyclopediaClapButton extends ConsumerStatefulWidget {
  const EncyclopediaClapButton({
    super.key,
    required this.articleId,
    required this.initialTotal,
    required this.initialMine,
  });

  final String articleId;
  final int initialTotal;
  final int? initialMine;

  @override
  ConsumerState<EncyclopediaClapButton> createState() =>
      _EncyclopediaClapButtonState();
}

class _EncyclopediaClapButtonState extends ConsumerState<EncyclopediaClapButton>
    with SingleTickerProviderStateMixin {
  static const _maxClaps = 50;

  late int _total;
  late int _mine;
  Timer? _syncTimer;
  bool _syncing = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _total = widget.initialTotal;
    _mine = widget.initialMine ?? 0;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 1,
      upperBound: 1.12,
    );
  }

  @override
  void didUpdateWidget(covariant EncyclopediaClapButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articleId != widget.articleId) {
      _total = widget.initialTotal;
      _mine = widget.initialMine ?? 0;
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 450), _flushSync);
  }

  Future<void> _flushSync() async {
    if (_syncing || !mounted) return;
    _syncing = true;
    final target = _mine;
    try {
      final resp = await ref
          .read(encyclopediaRepositoryProvider)
          .setClapCount(widget.articleId, target);
      if (!mounted) return;
      setState(() {
        _total = resp.data?.clapTotal ?? _total;
        _mine = resp.data?.count ?? target;
      });
    } catch (_) {
      // Biarkan angka optimistik; user bisa tap lagi.
    } finally {
      _syncing = false;
    }
  }

  Future<void> _onTap() async {
    if (_mine >= _maxClaps) return;
    final l10n = AppLocalizations.of(context);
    final okAuth = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaClapLoginBody,
    );
    if (!okAuth || !mounted) return;
    if (_mine >= _maxClaps) return;
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _mine += 1;
      _total += 1;
    });
    unawaited(_pulse.forward(from: 1));
    unawaited(_pulse.reverse());
    _scheduleSync();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final active = _mine > 0;

    return Semantics(
      button: true,
      label: l10n.encyclopediaClapSemantics(
        formatRibuan(_total),
        formatRibuan(_mine),
      ),
      child: FTappable(
        onPress: _onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: Icon(
                  active ? FLucideIcons.heart : FLucideIcons.heart,
                  size: 22,
                  color: active
                      ? theme.colors.primary
                      : theme.colors.mutedForeground,
                ),
              ),
              const Gap(8),
              Text(
                formatRibuan(_total),
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active
                      ? theme.colors.primary
                      : theme.colors.foreground,
                ),
              ),
              if (_mine > 0) ...[
                const Gap(4),
                Text(
                  l10n.encyclopediaClapYours(formatRibuan(_mine)),
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}