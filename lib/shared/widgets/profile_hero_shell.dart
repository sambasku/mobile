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

/// Peak alpha latar tombol/grup aksi di atas cover: tembus foto, ikon tetap
/// terbaca. Saat bar solid (t→1) fill jadi 0 lewat `(1 - t) * peak`.
const double _overlayFillPeak = 0.3;

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
    this.compactActions = false,
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

  /// Tinggi cover penuh (lebar / rasio asset). Sama dengan
  /// [ProfileIdentityHeader.coverHeightOf] varian + lebar layar.
  final double coverHeight;

  /// Kecilkan tombol aksi ke ukuran `FHeaderAction` supaya seragam dengan
  /// halaman ber-`FHeader` biasa. Default `false` (ukuran sentuh 48).
  final bool compactActions;

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
    _sync(notification.metrics);
    return false;
  }

  /// Ganti filter memangkas isi grid: offset di-clamp balik tanpa drag,
  /// jadi tak ada [ScrollNotification]. `ScrollMetricsNotification` tetap
  /// terkirim saat metrics berubah - tanpa ini bar bisa nyangkut solid
  /// (t = 1) padahal sudah kembali ke atas = area bar tampak gelap.
  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth != 0) return false;
    _sync(notification.metrics);
    return false;
  }

  void _sync(ScrollMetrics metrics) {
    final range = widget.coverHeight - ProfileHeroShell.barHeight;
    final t = range <= 0 ? 1.0 : (metrics.pixels / range).clamp(0.0, 1.0);
    if ((t - _t.value).abs() > 0.005) _t.value = t;
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
            NotificationListener<ScrollMetricsNotification>(
              onNotification: _onMetricsChanged,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                // Instance widget stabil: Stack rebuild per frame tidak
                // membangun ulang subtree isi halaman.
                child: widget.scrollView,
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: _buildBar(context, t)),
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
      // Tanpa border bawah: saat chip filter pin di bawah bar (profil
      // publik), garis di sini menempel di atas chip dan terlihat seperti
      // hairline ganda. Latar opaque sudah cukup memisahkan bar dari isi.
      decoration: BoxDecoration(
        color: theme.colors.background.withValues(alpha: t),
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
          if (widget.actions.isNotEmpty)
            widget.compactActions
                ? _ActionGroup(t: t, actions: widget.actions)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
    // Peak fill dibatasi supaya cover tembus (pins/wilayah tetap fill: 1).
    return IconButton(
      tooltip: tooltip,
      onPressed: onPress,
      // compactActions: kecilkan ke ukuran FHeaderAction Forui (44dp =
      // ikon 22 + padding 11 per sisi) supaya seragam dengan halaman
      // ber-FHeader biasa. shrinkWrap memotong tap target 48dp Material.
      visualDensity: widget.compactActions
          ? VisualDensity.compact
          : VisualDensity.standard,
      padding: widget.compactActions
          ? const EdgeInsets.all(11)
          : const EdgeInsets.all(8),
      constraints: widget.compactActions
          ? const BoxConstraints(minWidth: 44, minHeight: 44)
          : null,
      style:
          floatingOverlayIconButtonStyle(
            context,
            fill: (1 - t) * _overlayFillPeak,
          ).copyWith(
            tapTargetSize: widget.compactActions
                ? MaterialTapTargetSize.shrinkWrap
                : MaterialTapTargetSize.padded,
          ),
      icon: badgeCount > 0
          ? Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, size: widget.compactActions ? 22 : 20),
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
          : Icon(icon, size: widget.compactActions ? 22 : 20),
    );
  }
}

/// Grup aksi kanan: satu latar melayang (fill + elevation) untuk semua
/// tombol - gap antar tombol jadi bagian container sama, bukan dua kotak
/// terpisah. Saat bar solid (t = 1) fill memudar, tampak seperti suffixes
/// `FHeader` biasa.
class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.t, required this.actions});

  final double t;
  final List<ProfileHeroAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fill = (1 - t) * _overlayFillPeak;
    return Material(
      // Latar grup: gaya tombol back (square rounded + radius 10 + fill
      // memudar saat bar solid) - sekali untuk semua aksi.
      color: theme.colors.background.withValues(alpha: fill),
      elevation: 2 * fill,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            IconButton(
              tooltip: action.tooltip,
              onPressed: action.onPress,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: action.badgeCount > 0
                  ? Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(action.icon, size: 22),
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
                  : Icon(action.icon, size: 22),
            ),
        ],
      ),
    );
  }
}
