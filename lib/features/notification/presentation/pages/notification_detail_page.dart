import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_navigation.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/inbox_notification.dart';

/// Detail pengumuman. Tombol Buka di footer menjalankan deeplink.
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key, required this.item});

  final InboxNotification? item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final item = this.item;
    final kind = item?.actionKind?.trim();
    final value = item?.actionValue?.trim();
    final isUrl = kind == 'url';
    final canOpen =
        kind != null && kind.isNotEmpty && value != null && value.isNotEmpty;
    final imageUrl = item == null
        ? null
        : displayImageUrl(item.imageUrl, width: 800);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Pengumuman'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      footer: !canOpen || item == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    if (isUrl) ...[
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () async {
                            await Clipboard.setData(ClipboardData(text: value));
                            if (!context.mounted) return;
                            showFToast(
                              context: context,
                              title: const Text('Tautan disalin'),
                            );
                          },
                          child: const Text('Salin tautan'),
                        ),
                      ),
                      const Gap(8),
                    ],
                    Expanded(
                      child: FButton(
                        onPress: () =>
                            navigateFromInboxNotification(context, item),
                        child: const Text('Buka'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      child: item == null
          ? Center(
              child: Text(
                'Pengumuman tidak ditemukan',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                if (imageUrl != null) ...[
                  GestureDetector(
                    onTap: () => showImagePreview(
                      context,
                      urls: [item.imageUrl!],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImageWithFallback(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      Icon(
                        FLucideIcons.info,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(4),
                      Text(
                        'Ketuk untuk melihat gambar',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                ],
                Text(
                  item.title,
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  [
                    item.typeLabel,
                    formatDateTimeIso(item.createdAt),
                  ].where((part) => part.isNotEmpty).join(' · '),
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                if (item.body.isNotEmpty) ...[
                  const Gap(12),
                  Text(item.body, style: theme.typography.md),
                ],
              ],
            ),
    );
  }
}
