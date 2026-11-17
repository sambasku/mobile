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
    required this.busy,
    required this.uploading,
    required this.onPickImage,
    required this.onChanged,
  });

  final int slideIndex;
  final String mediaType;
  final ValueChanged<String> onMediaTypeChanged;
  final TextEditingController mediaUrl;
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
  }

  Future<void> _pick() async {
    if (widget.busy || widget.uploading.value) return;
    await widget.onPickImage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);

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
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: widget.mediaUrl,
                        ),
                        label: Text(l10n.balehoMediaUrlLabel),
                        hint: l10n.balehoMediaUrlHint,
                        enabled: !locked,
                        maxLines: 3,
                      ),
                      const Gap(6),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: locked ? null : _pick,
                        prefix: uploading
                            ? const FCircularProgress()
                            : null,
                        child: Text(
                          uploading
                              ? l10n.balehoUploading
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
