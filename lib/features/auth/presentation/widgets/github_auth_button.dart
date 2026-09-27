import 'package:flutter/widgets.dart';

import 'social_icon_button.dart';

/// Tombol GitHub icon-only. Mark hitam di-invert di dark mode.
class GithubAuthButton extends StatelessWidget {
  const GithubAuthButton({
    super.key,
    required this.onPress,
    this.isLoading = false,
  });

  final VoidCallback? onPress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SocialIconButton(
      assetPath: SocialIconButton.githubAsset,
      semanticLabel: 'Masuk dengan GitHub',
      invertInDark: true,
      isLoading: isLoading,
      onPress: onPress,
    );
  }
}
