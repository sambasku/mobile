import 'dart:io';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/discussion_providers.dart';
import '../../domain/discussion_models.dart';
import '../../discussion_router.dart';
import '../providers/discussion_list_providers.dart';

/// Form kirim diskusi (wajib login).
class CreateDiscussionPage extends HookConsumerWidget {
  const CreateDiscussionPage({super.key, this.autofocus = false});

  /// true saat dibuka dari composer feed (`?focus=1`).
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    final body = useTextEditingController();
    final link = useTextEditingController();
    final bodyFocus = useFocusNode();
    useListenable(body);
    useListenable(link);
    final images = useState<List<AttachmentImageSlot>>(const []);
    final attachmentsEnabled = useState(true);
    final shareSocialLink = useState(false);
    final pendingAudio = useState<RecordedThreadAudio?>(null);
    final submitting = useState(false);

    useEffect(() {
      if (!autofocus || !isAuth) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (bodyFocus.canRequestFocus) bodyFocus.requestFocus();
      });
      return null;
    }, [autofocus, isAuth]);

    final trimmed = body.text.trim();
    final linkTrimmed = shareSocialLink.value ? link.text.trim() : '';
    final canSubmit = isAuth && trimmed.isNotEmpty && !submitting.value;

    void promptLogin() {
      showFToast(
        context: context,
        title: Text(l10n.discussionLoginFirst),
        variant: FToastVariant.primary,
      );
      context.push('/login');
    }

    Future<void> pasteClipboard() async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) {
        if (!context.mounted) return;
        showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).discussionClipboardEmpty),
      );
        return;
      }
      final next = body.text.isEmpty ? text : '${body.text.trim()}\n$text';
      body.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }

    Future<void> pickAudio() async {
      if (!isAuth || submitting.value) {
        if (!isAuth) promptLogin();
        return;
      }
      final recorded = await showRecordThreadAudioSheet(
        context,
        title: l10n.discussionRecordSheetTitle,
        subtitle: l10n.discussionRecordSheetSubtitle,
        submitLabel: l10n.discussionRecordSheetUse,
      );
      if (recorded != null) {
        pendingAudio.value = recorded;
      }
    }

    Future<void> clearAudio() async {
      final prev = pendingAudio.value;
      pendingAudio.value = null;
      if (prev != null) {
        try {
          if (await prev.file.exists()) await prev.file.delete();
        } catch (_) {}
      }
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
          title: Text(AppLocalizations.of(context).discussionWaitUpload),
        );
        return;
      }

      submitting.value = true;
      try {
        final repo = ref.read(discussionRepositoryProvider);
        final ready = skipImages || !attachmentsEnabled.value
            ? const <AttachmentUploadedImage>[]
            : readyAttachmentImages(images.value);

        if (trimmed.isEmpty) {
          submitting.value = false;
          if (context.mounted) {
            await showAppErrorSheet(
              context,
              message: l10n.discussionBodyRequired,
            );
          }
          return;
        }

        if (linkTrimmed.isNotEmpty) {
          final uri = Uri.tryParse(linkTrimmed);
          if (uri == null ||
              !uri.hasScheme ||
              uri.scheme.toLowerCase() != 'https') {
            submitting.value = false;
            if (context.mounted) {
              await showAppErrorSheet(
                context,
                message: l10n.discussionLinkHttpsRequired,
              );
            }
            return;
          }
        }

        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            ready.isEmpty &&
            trimmed.isNotEmpty) {
          submitting.value = false;
          if (!context.mounted) return;
          final sendText = await showModalBottomSheet<bool>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            barrierColor: Colors.black54,
            builder: (sheetContext) => Padding(
              padding: MediaQuery.of(sheetContext).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTileGroup(
                    children: [
                      FTile(
                        title: Text(l10n.discussionAllImagesFailed),
                        subtitle: Text(l10n.discussionAllImagesFailedBody),
                      ),
                      FTile(
                        title: const Text(''),
                        suffix: FButton(
                          variant: FButtonVariant.destructive,
                          onPress: () => Navigator.of(sheetContext).pop(true),
                          child: Text(l10n.discussionSendWithoutImages),
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
          if (sendText == true) {
            await submit(skipImages: true);
          }
          return;
        }

        final result = await repo.create(
          body: trimmed,
          linkUrl: linkTrimmed.isEmpty ? null : linkTrimmed,
          images: [
            for (final u in ready)
              DiscussionImageRef(url: u.url, providerFileId: u.providerFileId),
          ],
        );

        final audio = pendingAudio.value;
        var audioFailed = false;
        if (audio != null) {
          final audioResult = await repo.attachTopicAudio(
            discussionId: result.id,
            audioFile: audio.file,
            durationMs: audio.durationMs,
          );
          audioResult.fold((_) => audioFailed = true, (_) {});
          try {
            if (await audio.file.exists()) await audio.file.delete();
          } catch (_) {}
          pendingAudio.value = null;
        }

        ref.invalidate(myDiscussionsProvider);
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text(
            audioFailed
                ? l10n.discussionSentAudioFailed
                : l10n.discussionSentPending,
          ),
        );
        context.pushReplacement(DiscussionRouter.detailPath(result.id));
      } on DioException catch (e) {
        if (context.mounted) {
          await showAppErrorSheet(context, message: _mapDio(e, l10n));
        }
      } on ImageUploadUnavailable {
        if (context.mounted) {
          await showAppErrorSheet(
            context,
            message: l10n.discussionStorageUnavailable,
          );
        }
      } catch (_) {
        if (context.mounted) {
          await showAppErrorSheet(
            context,
            message: l10n.discussionGenericError,
          );
        }
      } finally {
        submitting.value = false;
      }
    }

    final audio = pendingAudio.value;
    final audioSec = audio == null
        ? 0
        : (audio.durationMs / 1000).round().clamp(1, 60);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.discussionCreateTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(DiscussionRouter.feed.path),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FAlert(
            icon: Icon(FLucideIcons.info),
            title: Text(l10n.discussionCreateAlertTitle),
            subtitle: Text(
              l10n.discussionCreateAlertBody,
            ),
          ),
          const Gap(16),
          if (!isAuth) ...[
            FAlert(title: Text(l10n.discussionLoginFirst)),
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
            focusNode: bodyFocus,
            enabled: !submitting.value && isAuth,
            label: Text(l10n.discussionCreateBodyLabel),
            hint: l10n.discussionCreateBodyHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 4,
            maxLines: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: submitting.value || !isAuth ? null : pasteClipboard,
                  prefix: const Icon(FLucideIcons.clipboardPaste, size: 14),
                  child: Text(l10n.discussionCreatePaste),
                ),
                const Gap(4),
                Text(
                  l10n.discussionCreateCharCount(trimmed.length),
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FCheckbox(
                value: shareSocialLink.value,
                enabled: !submitting.value && isAuth,
                onChange: (v) {
                  shareSocialLink.value = v;
                  if (!v) link.clear();
                },
              ),
              const Gap(8),
              Expanded(
                child: GestureDetector(
                  onTap: submitting.value || !isAuth
                      ? null
                      : () {
                          final next = !shareSocialLink.value;
                          shareSocialLink.value = next;
                          if (!next) link.clear();
                        },
                  child: Text(
                    l10n.discussionCreateShareLink,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (shareSocialLink.value) ...[
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: link),
              enabled: !submitting.value && isAuth,
              label: Text(l10n.discussionCreateLinkLabel),
            hint: l10n.discussionCreateLinkHint,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
          ],
          const Gap(12),
          Text(
            l10n.discussionCreateAudioLabel,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          if (audio != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.discussionCreateAudioReady(audioSec),
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
                  child: Text(l10n.discussionCreateRerecord),
                ),
              ],
            )
          else
            FButton(
              variant: FButtonVariant.outline,
              onPress: submitting.value || !isAuth ? null : pickAudio,
              prefix: const Icon(FLucideIcons.mic, size: 14),
              child: Text(l10n.discussionCreateRecordCta),
            ),
          if (attachmentsEnabled.value) ...[
            const Gap(12),
            Text(
              l10n.discussionCreatePhotoLabel,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            AttachmentImagesField(
              enabled: !submitting.value && isAuth,
              maxImages: 4,
              maxSizeMb: 5,
              images: images.value,
              onChanged: (next) => images.value = next,
              disabledHint: l10n.discussionCreatePhotoLoginHint,
              disabledActionLabel: l10n.commonLoginRequiredShort,
              onDisabledAction: promptLogin,
              onUnavailable: () {
                attachmentsEnabled.value = false;
                images.value = const [];
              },
              upload: (File file, {required bool isPrimary}) async {
                final uploader = ref.read(discussionImageUploadServiceProvider);
                try {
                  final refImg = await uploader.upload(file);
                  return Either.right(
                    AttachmentUploadedImage(
                      url: refImg.url,
                      providerFileId: refImg.providerFileId,
                      isPrimary: isPrimary,
                    ),
                  );
                } on ImageUploadUnavailable {
                  return Either.left(
                    AttachmentUploadFailure(
                      l10n.discussionStorageUnavailable,
                      errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                    ),
                  );
                } on DioException catch (e) {
                  if (e.response?.statusCode == 503) {
                    return Either.left(
                      AttachmentUploadFailure(
                        l10n.discussionStorageUnavailable,
                        errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                      ),
                    );
                  }
                  return Either.left(
                    AttachmentUploadFailure(l10n.discussionImageUploadFailed),
                  );
                } catch (_) {
                  return Either.left(
                    AttachmentUploadFailure(l10n.discussionImageUploadFailed),
                  );
                }
              },
            ),
          ],
          const Gap(16),
          FButton(
            onPress: canSubmit
                ? () => submit()
                : (!isAuth ? promptLogin : null),
            prefix: submitting.value ? const FCircularProgress() : null,
            child: Text(
              submitting.value
                  ? l10n.discussionSending
                  : l10n.discussionSendCta,
            ),
          ),
        ],
      ),
    );
  }
}

String _mapDio(DioException error, AppLocalizations l10n) {
  final data = error.response?.data;
  if (data is Map &&
      data['message'] is String &&
      (data['message'] as String).isNotEmpty) {
    final message = data['message'] as String;
    if (error.response?.statusCode == 429) {
      final retry = error.response?.headers.value('retry-after');
      if (retry != null && retry.isNotEmpty) {
        return l10n.discussionRetryAfter(message, retry);
      }
    }
    return message;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      l10n.discussionServerOutdated,
    DioExceptionType.connectionError =>
      l10n.discussionConnectionFailed,
    _ => l10n.discussionGenericError,
  };
}
