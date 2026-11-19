import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
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

/// Label kecil "Jiku" di atas konten Jinye di profil.
class _JikuLabel extends StatelessWidget {
  const _JikuLabel();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      AppLocalizations.of(context).jinyeProfileJikuLabel,
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
class JinyeProfileStatusLine extends ConsumerWidget {
  const JinyeProfileStatusLine({
    super.key,
    required this.username,
    this.emptyChild,
  });

  final String username;

  /// Ditampilkan bila user belum punya Jinye published.
  final Widget? emptyChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(latestJinyeByUsernameProvider(username));
    final theme = context.theme;

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
              const _JikuLabel(),
              const Gap(4),
              FTappable(
                onPress: () => context.push(JinyeRouter.detailPath(item.id)),
                child: Semantics(
                  button: true,
                  label: l10n.jinyeProfilePreviewSemantics,
                  child: Row(
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
                              : FLucideIcons.quote,
                          size: 12,
                          color: item.isPinned
                              ? theme.colors.primary
                              : theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        const _JikuLabel(),
        const Gap(4),
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
                const _JikuLabel(),
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
              _openOwnerSheet(context, ref, item);
            } else {
              context.push(JinyeRouter.detailPath(item.id));
            }
          },
          semanticsLabel: l10n.jinyeProfilePreviewSemantics,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _JikuLabel(),
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

  /// Profil sendiri: sheet aksi (buat baru / kosongkan). Profil orang: tidak dipakai.
  Future<void> _openOwnerSheet(
    BuildContext context,
    WidgetRef ref,
    JinyeItem item,
  ) async {
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
                  prefix: const Icon(FLucideIcons.penLine, size: 18),
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
    if (action == 'create') {
      context.push(JinyeRouter.create.path);
      return;
    }
    if (action == 'clear') {
      await _confirmAndClearJinye(context, ref, item);
    }
  }

  Future<void> _confirmAndClearJinye(
    BuildContext context,
    WidgetRef ref,
    JinyeItem item,
  ) async {
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
