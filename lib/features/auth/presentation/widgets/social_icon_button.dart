import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';

/// Tombol sosial icon-only (Google / GitHub).
class SocialIconButton extends StatelessWidget {
  const SocialIconButton({
    super.key,
    required this.assetPath,
    required this.onPress,
    this.isLoading = false,
    this.semanticLabel,
    this.invertInDark = false,
  });

  final String assetPath;
  final VoidCallback? onPress;
  final bool isLoading;
  final String? semanticLabel;

  /// GitHub mark hitam → putih di dark mode.
  final bool invertInDark;

  static const googleAsset = 'assets/svg/google-icon.svg';
  static const githubAsset = 'assets/svg/github-icon.svg';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    final border = theme.colors.border;
    // Loading = spinner di tombol target (tetap opaque).
    // Disabled tanpa loading = pudar (aksi lain sedang jalan).
    final enabled = onPress != null && !isLoading;
    final faded = !enabled && !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Opacity(
        opacity: faded ? 0.45 : 1,
        child: Material(
          color: theme.colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          child: InkWell(
            onTap: enabled ? onPress : null,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: FCircularProgress(),
                      )
                    : SvgPicture.asset(
                        assetPath,
                        width: 24,
                        height: 24,
                        colorFilter: invertInDark && dark
                            ? const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              )
                            : null,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleAuthDivider extends StatelessWidget {
  const GoogleAuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.colors.mutedForeground.withValues(alpha: 0.25);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: muted)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: muted)),
      ],
    );
  }
}
