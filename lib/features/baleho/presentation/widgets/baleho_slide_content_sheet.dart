import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Bottom sheet kelola gambar satu slide. Judul/CTA/aksi = parent form, bukan di sini.
Future<void> showBalehoSlideContentSheet(
  BuildContext context, {
  required int slideIndex,
  required String mediaType,
  required ValueChanged<String> onMediaTypeChanged,
  required TextEditingController mediaUrl,
  required double aspectRatio,
  required bool busy,
  required ValueListenable<bool> uploading,
  required Future<void> Function() onPickImage,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: _BalehoSlideContentBody(
          slideIndex: slideIndex,
          mediaType: mediaType,
          onMediaTypeChanged: onMediaTypeChanged,
          mediaUrl: mediaUrl,
          aspectRatio: aspectRatio,
          busy: busy,
          uploading: uploading,
          onPickImage: onPickImage,
          onChanged: onChanged,
        ),
      );
    },
  );
}

class _BalehoSlideContentBody extends StatefulWidget {
  const _BalehoSlideContentBody({
    required this.slideIndex,
    required this.mediaType,
    required this.onMediaTypeChanged,
    required this.mediaUrl,
    required this.aspectRatio,
    required this.busy,
    required this.uploading,
    required this.onPickImage,
    required this.onChanged,
  });

  final int slideIndex;
  final String mediaType;
  final ValueChanged<String> onMediaTypeChanged;
  final TextEditingController mediaUrl;
  final double aspectRatio;
  final bool busy;
  final ValueListenable<bool> uploading;
  final Future<void> Function() onPickImage;
  final VoidCallback onChanged;

  @override
  State<_BalehoSlideContentBody> createState() =>
      _BalehoSlideContentBodyState();
}

class _BalehoSlideContentBodyState extends State<_BalehoSlideContentBody> {
  @override
  void initState() {
    super.initState();
    if (widget.mediaType != 'image') {
      widget.onMediaTypeChanged('image');
    }
    widget.mediaUrl.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    widget.mediaUrl.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _onUrlChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pick() async {
    if (widget.busy || widget.uploading.value) return;
    await widget.onPickImage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final url = widget.mediaUrl.text.trim();
    final hasImage = url.isNotEmpty;
    final ratio = widget.aspectRatio <= 0 ? 1.0 : widget.aspectRatio;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.uploading,
          builder: (context, uploading, _) {
            final locked = widget.busy || uploading;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.balehoSlideContentTitle(widget.slideIndex),
                          style: theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        onPress: uploading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(l10n.balehoSlideContentDone),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      AspectRatio(
                        aspectRatio: ratio,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colors.secondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colors.border,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: uploading
                                ? const Center(
                                    child: FCircularProgress(),
                                  )
                                : hasImage
                                    ? Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Icon(
                                            FLucideIcons.imageOff,
                                            color: theme.colors.mutedForeground,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          FLucideIcons.image,
                                          size: 36,
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: locked ? null : _pick,
                        prefix: uploading
                            ? const FCircularProgress()
                            : null,
                        child: Text(
                          uploading
                              ? l10n.balehoUploading
                              : hasImage
                                  ? l10n.balehoReplaceImage
                                  : l10n.balehoUploadImage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
