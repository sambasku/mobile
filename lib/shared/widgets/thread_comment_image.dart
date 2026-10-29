import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../core/utils/display_image_url.dart';
import '../../features/comment/domain/entities/comment_image.dart';
import '../../l10n/app_localizations.dart';
import 'cached_network_image_with_fallback.dart';
import 'word_image_view.dart';

/// Foto komentar di thread: pending chip, published URL, blur kekerasan.
class ThreadCommentImage extends StatefulWidget {
  const ThreadCommentImage({super.key, required this.image});

  final CommentImage image;

  @override
  State<ThreadCommentImage> createState() => _ThreadCommentImageState();
}

class _ThreadCommentImageState extends State<ThreadCommentImage> {
  var _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final img = widget.image;

    if (img.isPendingReview) {
      return _PendingChip(label: l10n.commentPhotoPending);
    }

    if (!img.hasDisplayableUrl) {
      return const SizedBox.shrink();
    }

    final url = img.publicUrl!;

    if (img.hasViolenceWarning && !_revealed) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Semantics(
            button: true,
            label: l10n.dictViolenceImage,
            child: GestureDetector(
              onTap: () async {
                final ok = await confirmRevealViolenceImage(context);
                if (ok && mounted) setState(() => _revealed = true);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: CachedNetworkImageWithFallback(
                      imageUrl: displayImageUrl(url, width: 800) ?? url,
                      fallbackUrl: url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  Center(
                    child: Text(
                      l10n.dictViolenceImage,
                      style: theme.typography.body.xs.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: CachedNetworkImageWithFallback(
          imageUrl: displayImageUrl(url, width: 800) ?? url,
          fallbackUrl: url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PendingChip extends StatelessWidget {
  const _PendingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FLucideIcons.image,
            size: 14,
            color: theme.colors.mutedForeground,
          ),
          const Gap(6),
          Flexible(
            child: Text(
              label,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
