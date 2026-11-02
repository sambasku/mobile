import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';
import 'social_icon_button.dart';

export 'social_icon_button.dart' show GoogleAuthDivider;

/// Tombol Google icon-only. Login dan register memakai widget yang sama.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.onPress,
    this.isLoading = false,
    this.label,
  });

  final VoidCallback? onPress;
  final bool isLoading;

  /// Diabaikan (kompatibilitas call site lama).
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SocialIconButton(
      assetPath: SocialIconButton.googleAsset,
      semanticLabel: label ?? AppLocalizations.of(context).authSignInWithGoogle,
      isLoading: isLoading,
      onPress: onPress,
    );
  }
}
