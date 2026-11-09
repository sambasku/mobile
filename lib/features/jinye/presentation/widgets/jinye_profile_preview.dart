import 'package:material_ui/material_ui.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';

/// Bubble chat preview Jinye di kanan atas avatar+border (max 32 char / label media).
class JinyeProfilePreview extends ConsumerWidget {
  const JinyeProfilePreview({
    super.key,
    required this.username,
    this.isOwnProfile = false,
  });

  final String username;
  final bool isOwnProfile;

  static const double _maxBubbleWidth = 176;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(latestJinyeByUsernameProvider(username));
    final theme = context.theme;

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (item) {
        if (item == null) {
          if (!isOwnProfile) return const SizedBox.shrink();
          return _ChatBubble(
            onTap: () => context.push(JinyeRouter.create.path),
            semanticsLabel: l10n.jinyeCreateTitle,
            child: Icon(
              FLucideIcons.penLine,
              size: 14,
              color: theme.colors.primary,
            ),
          );
        }

        final preview = _previewLabel(item, l10n);
        return _ChatBubble(
          onTap: () => _openSheet(context, item),
          semanticsLabel: l10n.jinyeProfilePreviewSemantics,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  item.isPinned
                      ? FLucideIcons.pin
                      : item.hasAudio
                      ? FLucideIcons.mic
                      : item.images.isNotEmpty
                      ? FLucideIcons.image
                      : FLucideIcons.messageCircle,
                  size: 12,
                  color: item.isPinned
                      ? theme.colors.primary
                      : theme.colors.mutedForeground,
                ),
              ),
              const Gap(5),
              Flexible(
                child: Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _previewLabel(JinyeItem item, AppLocalizations l10n) {
    final body = item.body.trim();
    if (body.isNotEmpty) return jinyeProfilePreviewText(body);
    if (item.hasAudio) return l10n.jinyePreviewVoiceOnly;
    if (item.images.isNotEmpty) return l10n.jinyePreviewPhotoOnly;
    return l10n.jinyePreviewEmpty;
  }

  Future<void> _openSheet(BuildContext context, JinyeItem item) async {
    final l10n = AppLocalizations.of(context);
    final path = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        final displayable = item.images
            .where((i) => i.displaySource != null)
            .take(4)
            .toList();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.displayName?.trim().isNotEmpty == true
                        ? item.displayName!
                        : (item.username ?? '-'),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  if (item.body.trim().isNotEmpty)
                    Text(item.body, style: theme.typography.body.md)
                  else if (!item.hasAudio && displayable.isEmpty)
                    Text(
                      item.images.isNotEmpty
                          ? l10n.jinyePhotosPendingReview
                          : l10n.jinyePreviewEmpty,
                      style: theme.typography.body.md,
                    ),
                  if (item.hasAudio) ...[
                    const Gap(12),
                    ThreadAudioPlayer(
                      url: item.audio!.url,
                      audioId: 'jinye-sheet:${item.id}',
                      durationMs: item.audio!.durationMs,
                    ),
                  ],
                  if (displayable.isNotEmpty) ...[
                    const Gap(12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayable.length,
                        separatorBuilder: (_, _) => const Gap(8),
                        itemBuilder: (context, index) {
                          final src = displayable[index].displaySource!;
                          final url =
                              displayImageUrl(src, width: 400) ?? src;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImageWithFallback(
                                imageUrl: url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (item.images.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      l10n.jinyePhotosPendingReview,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                  const Gap(16),
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(l10n.jinyeSheetReply),
                        onPress: () => Navigator.of(sheetContext)
                            .pop(JinyeRouter.detailPath(item.id)),
                      ),
                      FTile(
                        title: Text(l10n.jinyeSheetViewDiscussion),
                        onPress: () => Navigator.of(sheetContext)
                            .pop(JinyeRouter.detailPath(item.id)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (path != null && context.mounted) {
      context.push(path);
    }
  }
}

/// Bubble chat: badan rounded + ekor kiri-bawah mengarah ke avatar.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.onTap,
    required this.semanticsLabel,
    required this.child,
  });

  final VoidCallback onTap;
  final String semanticsLabel;
  final Widget child;

  static const double _tailSize = 8;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fill = theme.colors.background;
    final border = theme.colors.border;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: JinyeProfilePreview._maxBubbleWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colors.foreground.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  child: child,
                ),
              ),
              // Ekor mengarah ke avatar (bawah-kiri bubble).
              Transform.translate(
                offset: const Offset(14, -1),
                child: CustomPaint(
                  size: const Size(_tailSize + 4, _tailSize),
                  painter: _BubbleTailPainter(
                    fill: fill,
                    border: border,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round,
    );
    // Tutup garis atas ekor supaya tidak dobel dengan border badan.
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..color = fill
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.border != border;
}
