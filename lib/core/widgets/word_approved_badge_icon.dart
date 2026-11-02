import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import '../theme/f_colors_x.dart';

/// Ikon `circleDashedCheck` untuk kata yang sudah disetujui (terverifikasi).
///
/// Hijau [FColorsX.success] - khusus status kata, beda dari lencana biru
/// peran verifikator ([VerifiedBadgeIcon]).
class WordApprovedBadgeIcon extends StatelessWidget {
  const WordApprovedBadgeIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      FLucideIcons.circleDashedCheck,
      size: size,
      color: context.theme.colors.success,
    );
  }
}
