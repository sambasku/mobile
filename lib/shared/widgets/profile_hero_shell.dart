import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import 'floating_overlay_icon_button.dart';
import 'profile_identity_header.dart' show ProfileIdentityHeader;

/// Satu aksi ikon di bar melayang [ProfileHeroShell].
class ProfileHeroAction {
  const ProfileHeroAction({
    required this.icon,
    required this.tooltip,
    required this.onPress,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPress;

  /// 0 = tanpa badge. >99 tampil "99+".
  final int badgeCount;
}

/// Halaman profil dengan cover full-bleed dan bar aksi melayang di atasnya.
///
/// Cover tembus ke belakang status bar; tombol (back/edit/notifikasi) mengambang
/// dengan gaya sama peta eksplorasi (square rounded + elevation), lalu melebur
/// jadi bar solid berjudul saat cover tergulir habis. Hanya bar yang bergantung
/// pada posisi scroll - isi halaman ([scrollView]) dikirim sebagai widget utuh
/// supaya subtree-nya tidak ikut rebuild per frame.
class ProfileHeroShell extends StatefulWidget {
  const ProfileHeroShell({
    super.key,
    required this.scrollView,
    required this.title,
    this.actions = const [],
    this.showBack = false,
    this.onBack,
    this.backLabel = '',
    this.coverHeight = 160,
  });

  /// Isi halaman (scroll view). Harus mulai dari offset 0 di tepi atas layar.
  final Widget scrollView;

  /// Judul bar saat solid (nama tampilan profil).
  final String title;

  final List<ProfileHeroAction> actions;
  final bool showBack;
  final VoidCallback? onBack;

  /// Label aksesibilitas tombol kembali (ARB `commonBack`).
  final String backLabel;

  /// Tinggi cover di luar status bar. Sama dengan
  /// [ProfileIdentityHeader.coverHeightOf] varian yang dipakai.
  final double coverHeight;

  /// Tinggi bar di luar status bar.
  static const double barHeight = ProfileIdentityHeader.actionBarHeight;

  @override
  State<ProfileHeroShell> createState() => _ProfileHeroShellState();
}

class _ProfileHeroShellState extends State<ProfileHeroShell> {
  /// 0 = cover penuh (bar transparan), 1 = bar solid.
  final _t = ValueNotifier<double>(0);

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    // depth 0 = scroll utama halaman; chip horizontal di dalamnya diabaikan.
    if (notification.depth != 0) return false;
    final range = widget.coverHeight - ProfileHeroShell.barHeight;
    final t = range <= 0
        ? 1.0
        : (notification.metrics.pixels / range).clamp(0.0, 1.0);
    if ((t - _t.value).abs() > 0.005) _t.value = t;
    return false;
  }

  SystemUiOverlayStyle _overlayStyle(BuildContext context, double t) {
    // Di atas cover: paksa ikon terang (cover selalu digelapkan scrim atas).
    final light =
        t < 0.5 || context.theme.colors.background.computeLuminance() < 0.5;
    return light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _t,
      builder: (context, t, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: _overlayStyle(context, t),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              // Instance widget stabil: Stack rebuild per frame tidak
              // membangun ulang subtree isi halaman.
              child: widget.scrollView,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildBar(context, t),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double t) {
    final theme = context.theme;
    final topInset = MediaQuery.paddingOf(context).top;
    // Inset kiri 12: sama Positioned di pins/wilayah (top = status + 8
    // lewat tinggi bar + alignment Row).
    return Container(
      height: topInset + ProfileHeroShell.barHeight,
      padding: EdgeInsets.only(top: topInset, left: 12, right: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: theme.colors.background.withValues(alpha: t),
        border: t > 0.9
            ? Border(
                bottom: BorderSide(color: theme.colors.border, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          if (widget.showBack)
            _button(
              context,
              t,
              icon: FLucideIcons.arrowLeft,
              tooltip: widget.backLabel,
              onPress: widget.onBack ?? () {},
            ),
          Expanded(
            // Judul hanya dibangun setelah cover mulai tergulir: saat cover
            // penuh, nama sudah tampil besar di header identitas - teks judul
            // ganda membingungkan pembaca layar.
            child: t == 0
                ? const SizedBox.shrink()
                : Opacity(
                    opacity: t,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          for (final action in widget.actions)
            _button(
              context,
              t,
              icon: action.icon,
              tooltip: action.tooltip,
              onPress: action.onPress,
              badgeCount: action.badgeCount,
            ),
        ],
      ),
    );
  }

  Widget _button(
    BuildContext context,
    double t, {
    required IconData icon,
    String? tooltip,
    required VoidCallback onPress,
    int badgeCount = 0,
  }) {
    final theme = context.theme;
    // IconButton + style shared dengan peta: padding 8, elevation 2,
    // shadow Material - bukan BoxShadow manual / ukuran 40 tetap.
    return IconButton(
      tooltip: tooltip,
      onPressed: onPress,
      style: floatingOverlayIconButtonStyle(context, fill: 1 - t),
      icon: badgeCount > 0
          ? Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            )
          : Icon(icon, size: 20),
    );
  }
}
