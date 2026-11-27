import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/thread_edit_sheets.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';

String _jinyePreviewLabel(JinyeItem item, AppLocalizations l10n) {
  final body = item.body.trim();
  if (body.isNotEmpty) return jinyeProfilePreviewText(body);
  if (item.hasAudio) return l10n.jinyePreviewVoiceOnly;
  if (item.images.isNotEmpty) return l10n.jinyePreviewPhotoOnly;
  return l10n.jinyePreviewEmpty;
}

/// Label kecil "Jiku" (milik sendiri) / "Jinye" (orang lain) di profil.
class _JikuLabel extends StatelessWidget {
  const _JikuLabel({required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Text(
      isOwner ? l10n.jinyeProfileJikuLabel : l10n.jinyeDetailTitle,
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.1,
      ),
    );
  }
}

/// Baris status Jinye di profil: teks kecil, tanpa bubble overlay.
///
/// Pin profil bila ada, else Jinye published terbaru. Kosong =
/// [emptyChild] (mis. CTA buat Jinye di tab Profil) atau tidak dirender.

/// Baris status tipis tanpa kotak: ikon kutip + teks 1-2 baris + thumbnail 32px + chevron.
class _JikuInlineNote extends StatelessWidget {
  const _JikuInlineNote({required this.item, required this.preview});

  final JinyeItem item;
  final String preview;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    String? thumb;
    for (final image in item.images) {
      final src = image.displaySource;
      if (src != null) {
        thumb = src;
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FLucideIcons.quote, size: 14, color: theme.colors.primary),
          const Gap(8),
          Expanded(
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
                height: 1.3,
              ),
            ),
          ),
          if (thumb != null) ...[
            const Gap(8),
            SizedBox(
              width: 32,
              height: 32,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(thumb, width: 120) ?? thumb,
                  fallbackUrl: thumb,
                ),
              ),
            ),
          ],
          const Gap(4),
          Icon(
            FLucideIcons.chevronRight,
            size: 14,
            color: theme.colors.mutedForeground,
          ),
        ],
      ),
    );
  }
}

class JinyeProfileStatusLine extends ConsumerWidget {
  const JinyeProfileStatusLine({
    super.key,
    required this.username,
    this.emptyChild,
    this.ownerActions = false,
  });

  final String username;

  /// Ditampilkan bila user belum punya Jinye published.
  final Widget? emptyChild;

  /// Profil sendiri: sheet lihat / edit / kosongkan. Orang lain: buka detail.
  final bool ownerActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(latestJinyeByUsernameProvider(username));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => _wrapWithJiku(emptyChild),
      data: (item) {
        if (item == null) return _wrapWithJiku(emptyChild);
        final preview = _jinyePreviewLabel(item, l10n);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _JikuLabel(isOwner: ownerActions),
              const Gap(2),
              FTappable(
                onPress: () {
                  if (ownerActions) {
                    _openJikuOwnerSheet(context, ref, item, username: username);
                  } else {
                    context.push(JinyeRouter.detailPath(item.id));
                  }
                },
                child: Semantics(
                  button: true,
                  label: ownerActions
                      ? l10n.jinyeProfileJikuActionsSemantics
                      : l10n.jinyeProfilePreviewSemantics,
                  child: _JikuInlineNote(item: item, preview: preview),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _wrapWithJiku(Widget? child) {
    if (child == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JikuLabel(isOwner: ownerActions),
        const Gap(2),
        child,
      ],
    );
  }
}

/// Bubble chat preview Jinye di kanan atas avatar+border (max 32 char / label media).
///
/// Dipasang lewat [ProfileIdentityHeader.avatarOverlay] di profil publik.
/// Tab Profil pribadi pakai [JinyeProfileStatusLine] + CTA quote, bukan bubble.
class JinyeProfilePreview extends ConsumerWidget {
  const JinyeProfilePreview({
    super.key,
    required this.username,
    this.isOwnProfile = false,
  });

  final String username;
  final bool isOwnProfile;

  /// Lebar cukup untuk cuplikan 32 char 1 baris; bubble tumbuh ke kanan.
  /// Harus = [ProfileIdentityHeader.avatarOverlayMaxWidth].
  static const double maxBubbleWidth = 260;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JikuLabel(isOwner: isOwnProfile),
                const Gap(3),
                Icon(
                  FLucideIcons.penLine,
                  size: 14,
                  color: theme.colors.primary,
                ),
              ],
            ),
          );
        }

        final preview = _jinyePreviewLabel(item, l10n);
        return _ChatBubble(
          onTap: () {
            if (isOwnProfile) {
              _openJikuOwnerSheet(context, ref, item, username: username);
            } else {
              context.push(JinyeRouter.detailPath(item.id));
            }
          },
          semanticsLabel: l10n.jinyeProfilePreviewSemantics,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _JikuLabel(isOwner: isOwnProfile),
              const Gap(3),
              Row(
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
            ],
          ),
        );
      },
    );
  }
}

/// Profil sendiri: lihat, edit, atau kosongkan jiku.
Future<void> _openJikuOwnerSheet(
  BuildContext context,
  WidgetRef ref,
  JinyeItem item, {
  required String username,
}) async {
  final l10n = AppLocalizations.of(context);
  var handled = false;
  final action = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      void go(String value) {
        if (handled) return;
        handled = true;
        Navigator.of(sheetContext).pop(value);
      }

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.eye, size: 18),
                title: Text(l10n.jinyeSheetViewJiku),
                onPress: () => go('view'),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.pencil, size: 18),
                title: Text(l10n.jinyeSheetEditJiku),
                onPress: () => go('edit'),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.plus, size: 18),
                title: Text(l10n.jinyeSheetCreateNew),
                onPress: () => go('create'),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.archive, size: 18),
                title: Text(l10n.jinyeSheetClear),
                onPress: () => go('clear'),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.x, size: 18),
                title: Text(l10n.commonCancel),
                onPress: () {
                  if (handled) return;
                  handled = true;
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
  if (!context.mounted || action == null) return;
  if (action == 'view') {
    context.push(JinyeRouter.detailPath(item.id));
    return;
  }
  if (action == 'edit') {
    await _editJiku(context, ref, item, username: username);
    return;
  }
  if (action == 'create') {
    context.push(JinyeRouter.create.path);
    return;
  }
  if (action == 'clear') {
    await _confirmAndClearJinye(context, ref, item, username: username);
  }
}

Future<void> _editJiku(
  BuildContext context,
  WidgetRef ref,
  JinyeItem item, {
  required String username,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(jinyeRepositoryProvider);
  final saved = await showThreadTextEditSheet(
    context,
    title: l10n.jinyeEditTitle,
    initialBody: item.body,
    saveLabel: l10n.jinyeEditSave,
    onSave: (body) async {
      try {
        await repo.updateBody(id: item.id, body: body);
        return null;
      } on DioException catch (e) {
        final msg = e.response?.data is Map
            ? (e.response!.data as Map)['message']
            : null;
        return msg is String && msg.isNotEmpty ? msg : l10n.jinyeEditFailed;
      } catch (_) {
        return l10n.jinyeEditFailed;
      }
    },
  );
  if (saved == null || !context.mounted) return;
  ref.invalidate(jinyeDetailProvider(item.id));
  invalidateJinyeProfileSurfaces(ref, item.username ?? username);
  showFToast(context: context, title: Text(l10n.jinyeEditSuccess));
}

Future<void> _confirmAndClearJinye(
  BuildContext context,
  WidgetRef ref,
  JinyeItem item, {
  required String username,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.jinyeSheetClearConfirmTitle),
                  subtitle: Text(l10n.jinyeSheetClearConfirmBody),
                ),
                FTile(
                  title: Text(l10n.jinyeSheetClearConfirmAction),
                  onPress: () => Navigator.pop(sheetContext, true),
                ),
                FTile(
                  title: Text(l10n.commonCancel),
                  onPress: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;

  try {
    await ref.read(jinyeRepositoryProvider).archive(item.id);
    invalidateJinyeProfileSurfaces(ref, item.username ?? username);
    if (!context.mounted) return;
    showFToast(context: context, title: Text(l10n.jinyeClearedSuccess));
  } on DioException catch (e) {
    if (!context.mounted) return;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    await showAppErrorSheet(
      context,
      message: msg is String && msg.isNotEmpty
          ? msg
          : l10n.jinyeOwnerActionFailed,
    );
  } catch (_) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: l10n.jinyeOwnerActionFailed);
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

  static const double _tailW = 8;
  static const double _tailH = 7;
  // Ekor overlap ke badan supaya tidak ada celah di pojok kiri-bawah.
  static const double _tailOverlap = 3;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fill = theme.colors.background;
    final border = theme.colors.border;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: JinyeProfilePreview.maxBubbleWidth,
          ),
          // Stack: ekor menempel di bawah badan (bukan Column + gap).
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                // Sisakan ruang di bawah untuk ujung ekor.
                padding: const EdgeInsets.only(bottom: _tailH - _tailOverlap),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill,
                    // bottomLeft kecil: pojok rapat ke pangkal ekor.
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                      bottomLeft: Radius.circular(4),
                    ),
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
              ),
              Positioned(
                left: 2,
                bottom: 0,
                child: CustomPaint(
                  size: const Size(_tailW, _tailH),
                  painter: _BubbleTailPainter(fill: fill, border: border),
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
    // Segitiga: pangkal lebar di atas (masuk ke badan), ujung ke bawah-kiri.
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    // Stroke hanya sisi kiri + kanan (bukan pangkal atas).
    final stroke = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(
      stroke,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    // Tutup sambungan pangkal dengan fill badan (timpa border bawah).
    canvas.drawLine(
      const Offset(-0.5, 0),
      Offset(size.width + 0.5, 0),
      Paint()
        ..color = fill
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.border != border;
}
