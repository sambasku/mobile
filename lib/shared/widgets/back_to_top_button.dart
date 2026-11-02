import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/use_show_back_to_top.dart';
import '../../l10n/app_localizations.dart';
import 'floating_overlay_icon_button.dart';

/// Durasi animasi scroll ke atas (tap tombol).
const _scrollUpDuration = Duration(milliseconds: 320);

/// Bungkus [child] (scroll view) dengan tombol kembali ke atas di kanan bawah.
///
/// [controller] harus sama dengan yang terpasang di scroll view di dalam
/// [child]. Dipakai di feed panjang (beranda, diskusi, pantun, profil).
class ScrollWithBackToTop extends StatelessWidget {
  const ScrollWithBackToTop({
    super.key,
    required this.controller,
    required this.child,
    this.threshold = 480,
    this.bottom = 16,
    this.right = 12,
  });

  final ScrollController controller;
  final Widget child;
  final double threshold;
  final double bottom;
  final double right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        BackToTopButton(
          controller: controller,
          threshold: threshold,
          bottom: bottom,
          right: right,
        ),
      ],
    );
  }
}

/// Tombol mengambang "kembali ke atas" - wajib di dalam [Stack].
///
/// Muncul hanya jika [controller.offset] > [threshold]. Style sama tombol
/// overlay peta/profil ([floatingOverlayIconButtonStyle]).
class BackToTopButton extends HookWidget {
  const BackToTopButton({
    super.key,
    required this.controller,
    this.threshold = 480,
    this.bottom = 16,
    this.right = 12,
  });

  final ScrollController controller;
  final double threshold;
  final double bottom;
  final double right;

  @override
  Widget build(BuildContext context) {
    final visible = useShowBackToTop(controller, threshold: threshold);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      right: right,
      bottom: bottom + bottomInset,
      child: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (context, show, child) {
          return IgnorePointer(
            ignoring: !show,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: show ? 1 : 0.85,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: child,
              ),
            ),
          );
        },
        child: IconButton(
          tooltip: l10n.commonBackToTop,
          style: floatingOverlayIconButtonStyle(context),
          onPressed: () {
            if (!controller.hasClients) return;
            controller.animateTo(
              0,
              duration: _scrollUpDuration,
              curve: Curves.easeOutCubic,
            );
          },
          icon: const Icon(FLucideIcons.arrowUp, size: 20),
        ),
      ),
    );
  }
}
