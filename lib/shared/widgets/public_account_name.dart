import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../core/widgets/verified_badge_icon.dart';

/// Nama akun publik + centang verifikator.
///
/// Sama dengan baris komentar ruang diskusi: nama, lalu ikon centang hijau
/// hanya jika [isVerifier]. Letakkan di parent yang lebarnya terbatas
/// (Column, Expanded, Flexible) supaya nama panjang terpotong elipsis.
class PublicAccountName extends StatelessWidget {
  const PublicAccountName({
    super.key,
    required this.label,
    this.isVerifier = false,
    this.style,
    this.onTap,
    this.badgeSize = 13,
    this.maxLines = 1,
  });

  final String label;
  final bool isVerifier;
  final TextStyle? style;
  final VoidCallback? onTap;
  final double badgeSize;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
    final name = onTap == null
        ? text
        : Semantics(
            button: true,
            label: 'Lihat profil $label',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: text,
            ),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: name),
        if (isVerifier) ...[
          const Gap(3),
          Semantics(
            label: 'Verifikator',
            child: ExcludeSemantics(
              child: VerifiedBadgeIcon(size: badgeSize),
            ),
          ),
        ],
      ],
    );
  }
}
