import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/contribution/data/datasources/imagekit_uploader.dart';
import '../../features/contribution/data/models/upload_credentials_dto.dart';
import '../../l10n/app_localizations.dart';
import '../utils/error_bottom_sheet.dart';
import '../utils/image_sheet_drawer.dart';
import 'sticker_models.dart';
import 'sticker_providers.dart';

const _kMaxGifBytes = 2 * 1024 * 1024;
const _kCustomStickerFolder = '/stickers/custom';

/// Bottom sheet untuk membuat custom stiker privat user.
/// Mengembalikan `CatalogSticker` jika berhasil dibuat.
Future<CatalogSticker?> showCreateCustomStickerSheet(BuildContext context) {
  return showModalBottomSheet<CatalogSticker>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => const _CreateCustomStickerSheetBody(),
  );
}

class _CreateCustomStickerSheetBody extends ConsumerStatefulWidget {
  const _CreateCustomStickerSheetBody();

  @override
  ConsumerState<_CreateCustomStickerSheetBody> createState() =>
      _CreateCustomStickerSheetBodyState();
}

class _CreateCustomStickerSheetBodyState
    extends ConsumerState<_CreateCustomStickerSheetBody> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _pickedFile;
  var _isGif = false;
  var _picking = false;
  var _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_submitting || _picking) return;
    _picking = true;
    try {
      final file = await pickImageFromGalleryRaw(_picker);
      if (file == null || !mounted) return;
      final lower = file.path.toLowerCase();
      final isGif = lower.endsWith('.gif');
      if (isGif) {
        final bytes = await file.length();
        if (!mounted) return;
        if (bytes > _kMaxGifBytes) {
          final l10n = AppLocalizations.of(context);
          await showAppErrorSheet(
            context,
            message: l10n.stickerCreateGifTooLarge,
          );
          return;
        }
      }
      setState(() {
        _pickedFile = file;
        _isGif = isGif;
      });
    } catch (e, st) {
      debugPrint('[CustomSticker] pick image failed: $e\n$st');
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).imageSheetGalleryPickFailed),
      );
    } finally {
      _picking = false;
    }
  }

  Future<File> _prepareFile(File original, bool isGif) async {
    if (isGif) return original;
    try {
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/custom_sticker_${DateTime.now().millisecondsSinceEpoch}.webp';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        original.path,
        outPath,
        minWidth: 512,
        minHeight: 512,
        quality: 85,
        format: CompressFormat.webp,
      );
      if (compressed != null) {
        return File(compressed.path);
      }
    } catch (_) {
      // Fallback ke file asli bila kompresi tidak didukung platform test.
    }
    return original;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    final picked = _pickedFile;
    if (picked == null) {
      showFToast(context: context, title: Text(l10n.stickerCreateImageRequired));
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(stickerRepositoryProvider);
      final prepared = await _prepareFile(picked, _isGif);
      final creds = await repo.getUploadToken();
      final uploader = ImageKitUploader();
      final uploaded = await uploader.upload(
        file: prepared,
        creds: UploadCredentialsDto(
          token: creds.token,
          signature: creds.signature,
          expire: creds.expire,
          publicKey: creds.publicKey,
          uploadEndpoint: creds.uploadEndpoint,
        ),
        folder: _kCustomStickerFolder,
      );
      final created = await repo.createMine(
        name: _nameCtrl.text.trim(),
        imageUrl: uploaded.url,
        providerFileId: uploaded.fileId,
      );
      ref.read(myStickersProvider.notifier).prepend(created);
      if (!mounted) return;
      showFToast(context: context, title: Text(l10n.stickerCreateSuccess));
      Navigator.of(context).pop(created);
    } on StickerApiException catch (e) {
      if (!mounted) return;
      if (e.errorCode == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(l10n.commonRateLimited));
      } else {
        final msg = switch (e.errorCode) {
          'CUSTOM_STICKER_LIMIT_REACHED' => l10n.stickerCreateLimitReached,
          _ => e.message ?? l10n.stickerCreateFailed,
        };
        await showAppErrorSheet(context, message: msg);
      }
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.stickerCreateFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.stickerCreateTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              l10n.stickerCreateSubtitle,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(14),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.secondary.withValues(alpha: 0.6),
                      border: Border.all(color: theme.colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: 132,
                      height: 132,
                      child: _pickedFile != null
                          ? Image.file(
                              _pickedFile!,
                              fit: BoxFit.contain,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FLucideIcons.imagePlus,
                                  size: 28,
                                  color: theme.colors.mutedForeground,
                                ),
                                const Gap(6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    l10n.stickerCreatePickImage,
                                    textAlign: TextAlign.center,
                                    style: theme.typography.body.xs2.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            if (_pickedFile != null) ...[
              const Gap(8),
              Center(
                child: FButton(
                  variant: FButtonVariant.ghost,
                  onPress: _submitting ? null : _pickImage,
                  child: Text(l10n.stickerCreateChangeImage),
                ),
              ),
            ],
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(controller: _nameCtrl),
              label: Text(l10n.stickerCreateNameLabel),
              hint: l10n.stickerCreateNameHint,
              maxLength: 30,
              enabled: !_submitting,
            ),
            const Gap(16),
            FButton(
              onPress: _submitting ? null : _submit,
              prefix: _submitting ? const FCircularProgress() : null,
              child: Text(
                _submitting
                    ? l10n.stickerCreateSubmitting
                    : l10n.stickerCreateSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
