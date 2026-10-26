import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import '../../shared/utils/info_bottom_sheet.dart';
import '../theme/f_colors_x.dart';

/// Lencana `badgeCheck` biru untuk PERAN verifikator (di samping nama akun).
///
/// Biru [FColorsX.verifierBlue] supaya tidak tertukar dengan hijau status
/// kata terverifikasi (`WordApprovedBadgeIcon`).
class VerifiedBadgeIcon extends StatelessWidget {
  const VerifiedBadgeIcon({super.key, this.size = 18, this.onTap});

  final double size;

  /// Non-null = badge bisa di-tap (mis. info peran verifikator). Tap area
  /// diperluas 4px karena ikonnya kecil.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      FLucideIcons.badgeCheck,
      size: size,
      color: context.theme.colors.verifierBlue,
    );
    if (onTap == null) return icon;
    return Semantics(
      button: true,
      label: 'Verifikator, ketuk untuk info',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(4), child: icon),
      ),
    );
  }
}

/// Penjelasan lencana biru di samping akun. Label teks "Verifikator" tidak
/// dipakai lagi di UI - ikon sudah mewakilinya.
Future<void> showVerifierBadgeInfo(BuildContext context) => showAppInfoSheet(
      context,
      title: 'Verifikator',
      message:
          'Lencana biru menandai akun verifikator: warga yang memeriksa usulan '
          'kata dan kontribusi sebelum tayang.',
    );
