import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../core/utils/display_image_url.dart';

/// Avatar lingkaran kanonik (foto jaringan atau inisial).
///
/// Dipakai header thread komentar/balasan dan permukaan profil ringkas.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 36,
  });

  final String? name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final display = displayImageUrl(imageUrl, width: 256) ?? imageUrl;
    if (display != null && display.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          display,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            if (imageUrl != null &&
                imageUrl!.isNotEmpty &&
                imageUrl != display) {
              return Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _InitialsOrIcon(name: name, size: size),
              );
            }
            return _InitialsOrIcon(name: name, size: size);
          },
        ),
      );
    }
    return _InitialsOrIcon(name: name, size: size);
  }
}

class _InitialsOrIcon extends StatelessWidget {
  const _InitialsOrIcon({required this.name, required this.size});

  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initials = _initials(name);

    return FAvatar.raw(
      size: size,
      style: .delta(
        backgroundColor: initials != null
            ? theme.colors.primary.withValues(alpha: 0.12)
            : theme.colors.muted,
      ),
      child: initials != null
          ? Text(
              initials,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.primary,
                height: 1,
                fontSize: size * 0.32,
              ),
            )
          : Icon(
              FLucideIcons.userRound,
              size: size * 0.42,
              color: theme.colors.mutedForeground,
            ),
    );
  }

  static String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final word = parts.first;
    if (word.length >= 2) return word.substring(0, 2).toUpperCase();
    return word.toUpperCase();
  }
}
