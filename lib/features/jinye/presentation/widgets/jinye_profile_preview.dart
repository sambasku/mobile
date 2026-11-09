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

/// Baris preview Jinye di profil (max 32 char / label media). Tap → bottom sheet.
class JinyeProfilePreview extends ConsumerWidget {
  const JinyeProfilePreview({
    super.key,
    required this.username,
    this.isOwnProfile = false,
  });

  final String username;
  final bool isOwnProfile;

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
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push(JinyeRouter.create.path),
              child: Text(l10n.jinyeCreateTitle),
            ),
          );
        }

        final preview = _previewLabel(item, l10n);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GestureDetector(
            onTap: () => _openSheet(context, item),
            child: Semantics(
              button: true,
              label: l10n.jinyeProfilePreviewSemantics,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (item.isPinned) ...[
                      Icon(
                        FLucideIcons.pin,
                        size: 16,
                        color: theme.colors.primary,
                      ),
                      const Gap(8),
                    ] else if (item.hasAudio) ...[
                      Icon(
                        FLucideIcons.mic,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(8),
                    ] else if (item.images.isNotEmpty) ...[
                      Icon(
                        FLucideIcons.image,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(8),
                    ],
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm,
                      ),
                    ),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
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
