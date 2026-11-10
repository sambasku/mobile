import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';
import '../utils/jinye_quota_message.dart';

/// Form kirim Jinye (teks / suara / foto). CTA di [FScaffold.footer].
class CreateJinyePage extends HookConsumerWidget {
  const CreateJinyePage({super.key});

  static const _maxBody = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final body = useTextEditingController();
    useListenable(body);
    final images = useState<List<AttachmentImageSlot>>(const []);
    final attachmentsEnabled = useState(true);
    final pendingAudio = useState<RecordedThreadAudio?>(null);
    final submitting = useState(false);
    // Opsi 2: panel media collapsible - chip buka on-demand.
    final showAudioPanel = useState(false);
    final showPhotoPanel = useState(false);

    final trimmed = body.text.trim();
    final hasImagesReady = readyAttachmentImages(images.value).isNotEmpty;
    final hasAudio = pendingAudio.value != null;
    final canSubmit = isAuth &&
        !submitting.value &&
        trimmed.length <= _maxBody &&
        (trimmed.isNotEmpty || hasImagesReady || hasAudio) &&
        !images.value.any((e) => e.uploading);

    void promptLogin() {
      showFToast(
        context: context,
        title: Text(l10n.jinyeLoginFirst),
      );
      context.push('/login');
    }

    Future<void> pickAudio() async {
      if (!isAuth || submitting.value) {
        if (!isAuth) promptLogin();
        return;
      }
      final recorded = await showRecordThreadAudioSheet(
        context,
        title: l10n.jinyeRecordSheetTitle,
        subtitle: l10n.jinyeRecordSheetSubtitle,
        submitLabel: l10n.jinyeRecordSheetUse,
      );
      if (recorded != null) {
        pendingAudio.value = recorded;
        showAudioPanel.value = true;
      }
    }

    Future<void> clearAudio() async {
      final prev = pendingAudio.value;
      pendingAudio.value = null;
      showAudioPanel.value = false;
      if (prev != null) {
        try {
          if (await prev.file.exists()) await prev.file.delete();
        } catch (_) {}
      }
    }

    Future<void> toggleAudioChip() async {
      if (!isAuth) {
        promptLogin();
        return;
      }
      if (submitting.value) return;
      if (showAudioPanel.value) {
        showAudioPanel.value = false;
        return;
      }
      showAudioPanel.value = true;
      if (pendingAudio.value == null) {
        await pickAudio();
        if (pendingAudio.value == null) {
          showAudioPanel.value = false;
        }
      }
    }

    void togglePhotoChip() {
      if (!isAuth) {
        promptLogin();
        return;
      }
      if (!attachmentsEnabled.value || submitting.value) return;
      showPhotoPanel.value = !showPhotoPanel.value;
    }

    Future<void> submit({bool skipImages = false}) async {
      if (!isAuth) {
        promptLogin();
        return;
      }
      if (!canSubmit && !skipImages) return;

      if (!skipImages &&
          attachmentsEnabled.value &&
          images.value.any((e) => e.uploading)) {
        showFToast(
          context: context,
          title: Text(l10n.jinyeWaitUpload),
        );
        return;
      }

      submitting.value = true;
      try {
        final repo = ref.read(jinyeRepositoryProvider);
        final ready = skipImages || !attachmentsEnabled.value
            ? const <AttachmentUploadedImage>[]
            : readyAttachmentImages(images.value);

        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            ready.isEmpty &&
            trimmed.isEmpty &&
            !hasAudio) {
          submitting.value = false;
          if (context.mounted) {
            await showAppErrorSheet(
              context,
              message: l10n.jinyeComposeNeedContent,
            );
          }
          return;
        }

        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            ready.isEmpty &&
            (trimmed.isNotEmpty || hasAudio)) {
          submitting.value = false;
          if (!context.mounted) return;
          final sendAnyway = await showModalBottomSheet<bool>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (sheetContext) => Padding(
              padding: MediaQuery.of(sheetContext).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(l10n.jinyeAllImagesFailed),
                        subtitle: Text(l10n.jinyeAllImagesFailedBody),
                      ),
                      FTile(
                        title: const Text(''),
                        suffix: FButton(
                          variant: FButtonVariant.destructive,
                          onPress: () => Navigator.of(sheetContext).pop(true),
                          child: Text(l10n.jinyeSendWithoutImages),
                        ),
                      ),
                      FTile(
                        title: const Text(''),
                        suffix: FButton(
                          onPress: () => Navigator.of(sheetContext).pop(false),
                          child: Text(l10n.commonCancel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          if (sendAnyway == true) {
            await submit(skipImages: true);
          }
          return;
        }

        final audio = pendingAudio.value;
        final voiceOnly =
            trimmed.isEmpty && ready.isEmpty && audio != null;

        final item = await repo.create(
          body: trimmed,
          images: [
            for (final u in ready)
              JinyeImageRef(url: u.url, providerFileId: u.providerFileId),
          ],
          hasPendingAudio: voiceOnly,
        );

        var audioFailed = false;
        var result = item;
        if (audio != null) {
          try {
            result = await repo.attachAudio(
              jinyeId: item.id,
              audioFile: audio.file,
              durationMs: audio.durationMs,
            );
          } catch (_) {
            audioFailed = true;
            if (voiceOnly) {
              try {
                await repo.delete(item.id);
              } catch (_) {}
              rethrow;
            }
          } finally {
            try {
              if (await audio.file.exists()) await audio.file.delete();
            } catch (_) {}
            pendingAudio.value = null;
          }
        }

        // Bubble + timeline profil + feed: tanpa ini Jinye baru tidak muncul
        // sampai pull-to-refresh / cold start.
        invalidateJinyeProfileSurfaces(ref, auth?.username);
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text(
            audioFailed ? l10n.jinyeSentAudioFailed : l10n.jinyeCreateSuccess,
          ),
        );
        // pushReplacement: stack tetap punya layar sebelumnya (bukan go kosong).
        context.pushReplacement(JinyeRouter.detailPath(result.id));
      } on DioException catch (e) {
        if (!context.mounted) return;
        await showAppErrorSheet(context, message: _mapDio(e, l10n));
      } on JinyeImageUploadUnavailable {
        if (!context.mounted) return;
        await showAppErrorSheet(
          context,
          message: l10n.jinyeStorageUnavailable,
        );
      } catch (_) {
        if (!context.mounted) return;
        await showAppErrorSheet(context, message: l10n.jinyeCreateFailed);
      } finally {
        submitting.value = false;
      }
    }

    final audio = pendingAudio.value;
    final audioSec = audio == null
        ? 0
        : (audio.durationMs / 1000).round().clamp(1, 60);

    // childPad Forui sudah kasih gutter horizontal - jangan dobel di ListView.
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.jinyeCreateTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: canSubmit
                ? () => submit()
                : (!isAuth ? promptLogin : null),
            prefix: submitting.value ? const FCircularProgress() : null,
            child: Text(
              submitting.value
                  ? l10n.jinyeCreateSubmitting
                  : l10n.jinyeCreateSubmit,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (!isAuth) ...[
            FAlert(title: Text(l10n.jinyeLoginFirst)),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: promptLogin,
              child: Text(l10n.commonLoginRequiredShort),
            ),
            const Gap(12),
          ],
          FTextField(
            control: FTextFieldControl.managed(controller: body),
            maxLines: 6,
            maxLength: _maxBody,
            label: Text(l10n.jinyeCreateBodyLabel),
            hint: l10n.jinyeCreateBodyHint,
            enabled: !submitting.value && isAuth,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 3,
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FButton(
                variant: (showAudioPanel.value || audio != null)
                    ? FButtonVariant.primary
                    : FButtonVariant.outline,
                onPress: submitting.value ? null : toggleAudioChip,
                prefix: const Icon(FLucideIcons.mic, size: 14),
                child: Text(
                  audio != null
                      ? l10n.jinyeCreateChipAudioReady(audioSec)
                      : l10n.jinyeCreateChipAudio,
                ),
              ),
              if (attachmentsEnabled.value)
                FButton(
                  variant: (showPhotoPanel.value || images.value.isNotEmpty)
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: submitting.value ? null : togglePhotoChip,
                  prefix: const Icon(FLucideIcons.image, size: 14),
                  child: Text(
                    images.value.isEmpty
                        ? l10n.jinyeCreateChipPhoto
                        : l10n.jinyeCreateChipPhotoCount(images.value.length),
                  ),
                ),
            ],
          ),
          if (showAudioPanel.value && audio != null) ...[
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.jinyeCreateAudioReady(audioSec),
                    style: context.theme.typography.body.sm,
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: submitting.value ? null : clearAudio,
                  child: Text(l10n.commonDelete),
                ),
                const Gap(4),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: submitting.value || !isAuth ? null : pickAudio,
                  prefix: const Icon(FLucideIcons.mic, size: 14),
                  child: Text(l10n.jinyeCreateRerecord),
                ),
              ],
            ),
          ],
          if (attachmentsEnabled.value && showPhotoPanel.value) ...[
            const Gap(8),
            AttachmentImagesField(
              // Foto pertama: chip → langsung sheet Kamera/Galeri.
              openPickerOnMount: images.value.isEmpty,
              enabled: !submitting.value && isAuth,
              maxImages: 4,
              maxSizeMb: 5,
              images: images.value,
              onChanged: (next) {
                images.value = next;
                if (next.isNotEmpty) showPhotoPanel.value = true;
              },
              disabledHint: l10n.jinyeCreatePhotoLoginHint,
              disabledActionLabel: l10n.commonLoginRequiredShort,
              onDisabledAction: promptLogin,
              onUnavailable: () {
                attachmentsEnabled.value = false;
                images.value = const [];
                showPhotoPanel.value = false;
              },
              upload: (File file, {required bool isPrimary}) async {
                final uploader = ref.read(jinyeImageUploadServiceProvider);
                try {
                  final refImg = await uploader.upload(file);
                  return Either.right(
                    AttachmentUploadedImage(
                      url: refImg.url,
                      providerFileId: refImg.providerFileId,
                      isPrimary: isPrimary,
                    ),
                  );
                } on JinyeImageUploadUnavailable {
                  return Either.left(
                    AttachmentUploadFailure(
                      l10n.jinyeStorageUnavailable,
                      errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                    ),
                  );
                } on DioException catch (e) {
                  if (e.response?.statusCode == 503) {
                    return Either.left(
                      AttachmentUploadFailure(
                        l10n.jinyeStorageUnavailable,
                        errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                      ),
                    );
                  }
                  return Either.left(
                    AttachmentUploadFailure(l10n.jinyeImageUploadFailed),
                  );
                } catch (_) {
                  return Either.left(
                    AttachmentUploadFailure(l10n.jinyeImageUploadFailed),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

String _mapDio(DioException error, AppLocalizations l10n) {
  final code = error.response?.data is Map
      ? (error.response!.data as Map)['error_code']
      : null;
  if (code == 'RATE_LIMITED') {
    return jinyeQuotaRateLimitedMessage(error, l10n);
  }
  final msg = error.response?.data is Map
      ? (error.response!.data as Map)['message']
      : null;
  if (msg is String && msg.trim().isNotEmpty) return msg;
  return l10n.jinyeCreateFailed;
}
