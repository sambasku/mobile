import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import '../theme/f_colors_x.dart';
import '../../l10n/app_localizations.dart';

/// Ikon `clock` untuk kata yang masih menunggu pengecekan.
/// Warna [FColorsX.warning] menyesuaikan light/dark.
class PendingReviewBadgeIcon extends StatelessWidget {
  const PendingReviewBadgeIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      FLucideIcons.clock,
      size: size,
      color: context.theme.colors.warning,
    );
  }
}

/// Penjelasan status - dipanggil saat ikon di-tap (bukan teks permanen).
void showPendingReviewInfo(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showFToast(
    context: context,
    title: Text(l10n.pendingCheckTitle),
    description: Text(l10n.pendingCheckWordBody),
  );
}

/// Sama seperti [showPendingReviewInfo], untuk audio pelafalan.
void showPendingAudioReviewInfo(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showFToast(
    context: context,
    title: Text(l10n.pendingCheckTitle),
    description: Text(l10n.pendingCheckAudioBody),
  );
}
