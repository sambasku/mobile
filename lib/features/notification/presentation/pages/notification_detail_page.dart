import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_navigation.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../activity/presentation/widgets/announcement_body.dart';
import '../../domain/entities/inbox_notification.dart';
import '../notification_labels.dart';

/// Detail pengumuman. Tombol Buka di footer menjalankan deeplink.
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key, required this.item});

  final InboxNotification? item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.announcementTitle),
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
                              title: Text(l10n.notificationLinkCopied),
                            );
                          },
                          child: Text(l10n.notificationCopyLink),
                        ),
                      ),
                      const Gap(8),
                    ],
                    Expanded(
                      child: FButton(
                        onPress: () =>
                            navigateFromInboxNotification(context, item),
                        child: Text(l10n.notificationOpen),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      child: item == null
          ? Center(
              child: Text(
                l10n.notificationAnnouncementMissing,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (imageUrl != null) ...[
                  GestureDetector(
                    onTap: () =>
                        showImagePreview(context, urls: [item.imageUrl!]),
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
                        l10n.notificationTapImage,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                ],
                Text(
                  item.title,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  [
                    notificationTypeLabel(l10n, item.type),
                    formatDateTimeIso(item.createdAt),
                  ].where((part) => part.isNotEmpty).join(' · '),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                if (item.body.isNotEmpty) ...[
                  const Gap(12),
                  AnnouncementBody(body: item.body, bodyType: item.bodyType),
                ],
              ],
            ),
    );
  }
}
