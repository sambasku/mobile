import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/widgets/attachment_images_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/error_bottom_sheet.dart';
import '../../../core/services/analytics_service.dart';
import '../../auth/presentation/providers/auth_status_providers.dart';
import '../data/bug_report_providers.dart';
import '../domain/bug_report_models.dart';

class ReportBugPage extends HookConsumerWidget {
  const ReportBugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final description = useTextEditingController();
    useListenable(description);
    final images = useState<List<AttachmentImageSlot>>(const []);
    final attachmentsEnabled = useState(true);
    final submitting = useState(false);
    final isGuest = !(ref.watch(authStatusProvider).value?.isAuth ?? false);

    final trimmed = description.text.trim();
    final canSubmit = trimmed.length >= 10 && !submitting.value;

    Future<void> submit({bool skipImages = false}) async {
      if (!canSubmit) return;

      if (!skipImages &&
          attachmentsEnabled.value &&
          images.value.any((e) => e.uploading)) {
        showFToast(
          context: context,
          title: Text(l10n.reportBugWaitUpload),
        );
        return;
      }

      submitting.value = true;
      try {
        final repo = ref.read(bugReportRepositoryProvider);
        final ready = skipImages || !attachmentsEnabled.value
            ? const <AttachmentUploadedImage>[]
            : readyAttachmentImages(images.value);

        // Soft-fail: semua slot error / belum siap padahal user lampirkan.
        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            ready.isEmpty) {
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
                        title: Text(l10n.reportBugAllImagesFailedTitle),
                        subtitle: Text(
                          l10n.reportBugAllImagesFailedBody,
                        ),
                      ),
                      FTile(
                        title: const Text(''),
                        suffix: FButton(
                          variant: FButtonVariant.destructive,
                          onPress: () => Navigator.of(sheetContext).pop(true),
                          child: Text(l10n.reportBugSendWithoutImages),
                        ),
                      ),
                      FTile(
                        title: const Text(''),
                        suffix: FButton(
                          onPress: () => Navigator.of(sheetContext).pop(false),
                          child: Text(l10n.reportBugCancel),
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

        final info = await PackageInfo.fromPlatform();
        final platform = defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : defaultTargetPlatform == TargetPlatform.android
            ? 'android'
            : null;

        await repo.submit(
          description: trimmed,
          images: [
            for (final u in ready)
              BugReportImageRef(url: u.url, providerFileId: u.providerFileId),
          ],
          appVersion: info.version,
          platform: platform,
        );

        AnalyticsService.instance.log(
          AnalyticsEvents.reportBugSubmit,
          params: {
            'has_word': 0,
            'has_comment': 0,
            'has_images': ready.isEmpty ? 0 : 1,
          },
        );

        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text(l10n.reportBugThanks),
        );
        context.pop();
      } on DioException catch (e) {
        if (context.mounted) {
          await showAppErrorSheet(context, message: _mapDio(e, l10n));
        }
      } catch (_) {
        if (context.mounted) {
          await showAppErrorSheet(
            context,
            message: l10n.reportBugGenericError,
          );
        }
      } finally {
        submitting.value = false;
      }
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.reportBugTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (isGuest) ...[
            FAlert(title: Text(l10n.reportBugGuestAnonymous)),
            const Gap(4),
            Text(
              l10n.reportBugGuestLoginHint,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const Gap(12),
          ],
          FTextField(
            control: FTextFieldControl.managed(controller: description),
            enabled: !submitting.value,
            label: Text(l10n.reportBugDescriptionLabel),
            hint:
                l10n.reportBugDescriptionHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${trimmed.length}/2000',
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          if (attachmentsEnabled.value && !isGuest) ...[
            const Gap(8),
            Text(
              l10n.reportBugAttachmentsLabel,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            AttachmentImagesField(
              enabled: !submitting.value,
              maxImages: 4,
              maxSizeMb: 5,
              images: images.value,
              onChanged: (next) => images.value = next,
              onUnavailable: () {
                attachmentsEnabled.value = false;
                images.value = const [];
                // Soft-fail: tawarkan kirim tanpa gambar jika sudah ada teks.
                if (trimmed.length >= 10) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                                  title: Text(l10n.reportBugImagesUnavailableTitle),
                                  subtitle: Text(
                                    l10n.reportBugImagesUnavailableBody,
                                  ),
                                ),
                                FTile(
                                  title: const Text(''),
                                  suffix: FButton(
                                    variant: FButtonVariant.destructive,
                                    onPress: () =>
                                        Navigator.of(sheetContext).pop(true),
                                    child: Text(l10n.reportBugSendWithoutImages),
                                  ),
                                ),
                                FTile(
                                  title: const Text(''),
                                  suffix: FButton(
                                    onPress: () =>
                                        Navigator.of(sheetContext).pop(false),
                                    child: Text(l10n.reportBugCancel),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                    if (sendText == true && context.mounted) {
                      await submit(skipImages: true);
                    }
                  });
                }
              },
              upload: (File file, {required bool isPrimary}) async {
                final uploader = ref.read(reportImageUploadServiceProvider);
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
                    const AttachmentUploadFailure(
                      'Penyimpanan gambar belum tersedia',
                      errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                    ),
                  );
                } on DioException catch (e) {
                  if (e.response?.statusCode == 503) {
                    return Either.left(
                      const AttachmentUploadFailure(
                        'Penyimpanan gambar belum tersedia',
                        errorCode: 'IMAGE_UPLOAD_UNAVAILABLE',
                      ),
                    );
                  }
                  return Either.left(
                    const AttachmentUploadFailure('Satu gambar gagal diunggah'),
                  );
                } catch (_) {
                  return Either.left(
                    const AttachmentUploadFailure('Satu gambar gagal diunggah'),
                  );
                }
              },
            ),
          ],
          const Gap(16),
          FButton(
            onPress: canSubmit ? () => submit() : null,
            prefix: submitting.value ? const FCircularProgress() : null,
            child: Text(submitting.value ? l10n.reportBugSubmitting : l10n.reportBugSubmit),
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
        return l10n.reportBugRateLimited(message, retry);
      }
    }
    return message;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      l10n.reportBugTimeout,
    DioExceptionType.connectionError =>
      l10n.reportBugConnectionError,
    _ => l10n.reportBugGenericError,
  };
}
