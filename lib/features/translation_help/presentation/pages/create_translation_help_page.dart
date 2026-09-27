import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/translation_help_providers.dart';
import '../../domain/translation_help_models.dart';
import '../../translation_help_router.dart';
import '../providers/translation_help_list_providers.dart';

/// Form kirim permintaan bantuan (wajib login).
class CreateTranslationHelpPage extends HookConsumerWidget {
  const CreateTranslationHelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    final body = useTextEditingController();
    useListenable(body);
    final images = useState<List<AttachmentImageSlot>>(const []);
    final attachmentsEnabled = useState(true);
    final submitting = useState(false);
    final errorMessage = useState<String?>(null);

    final trimmed = body.text.trim();
    final readyImages = readyAttachmentImages(images.value);
    final hasContent = trimmed.isNotEmpty || readyImages.isNotEmpty;
    final canSubmit = isAuth && hasContent && !submitting.value;

    void promptLogin() {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk meminta bantuan'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
    }

    Future<void> pasteClipboard() async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) {
        if (!context.mounted) return;
        showFToast(context: context, title: const Text('Clipboard kosong'));
        return;
      }
      final next = body.text.isEmpty ? text : '${body.text.trim()}\n$text';
      body.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
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
          title: const Text('Tunggu upload gambar selesai'),
        );
        return;
      }

      submitting.value = true;
      errorMessage.value = null;
      try {
        final repo = ref.read(translationHelpRepositoryProvider);
        final ready = skipImages || !attachmentsEnabled.value
            ? const <AttachmentUploadedImage>[]
            : readyAttachmentImages(images.value);

        if (trimmed.isEmpty && ready.isEmpty) {
          errorMessage.value = 'Isi teks atau unggah minimal 1 gambar';
          return;
        }

        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            ready.isEmpty &&
            trimmed.isNotEmpty) {
          submitting.value = false;
          if (!context.mounted) return;
          final sendText = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Semua gambar gagal'),
              content: const Text(
                'Teks tetap bisa dikirim tanpa lampiran. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Kirim tanpa gambar'),
                ),
              ],
            ),
          );
          if (sendText == true) {
            await submit(skipImages: true);
          }
          return;
        }

        final result = await repo.create(
          body: trimmed.isEmpty ? null : trimmed,
          images: [
            for (final u in ready)
              TranslationHelpImageRef(
                url: u.url,
                providerFileId: u.providerFileId,
              ),
          ],
        );

        ref.invalidate(myTranslationHelpsProvider);
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: const Text('Permintaan terkirim, menunggu pengecekan'),
        );
        context.pushReplacement(TranslationHelpRouter.detailPath(result.id));
      } on DioException catch (e) {
        errorMessage.value = _mapDio(e);
      } on ImageUploadUnavailable {
        errorMessage.value = 'Penyimpanan gambar belum tersedia';
      } catch (_) {
        errorMessage.value = 'Terjadi kesalahan, coba lagi';
      } finally {
        submitting.value = false;
      }
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Minta Bantuan'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(TranslationHelpRouter.feed.path),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const FAlert(
            icon: Icon(FLucideIcons.info),
            title: Text('Diperiksa tim sebelum tayang'),
            subtitle: Text(
              'Kirim teks atau foto yang sulit diterjemahkan. Setelah disetujui, permintaanmu tampil dan warga bisa membalas.',
            ),
          ),
          const Gap(16),
          if (!isAuth) ...[
            const FAlert(title: Text('Masuk dulu untuk mengirim permintaan')),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: promptLogin,
              child: const Text('Masuk'),
            ),
            const Gap(12),
          ],
          FTextField(
            control: FTextFieldControl.managed(controller: body),
            enabled: !submitting.value && isAuth,
            label: const Text('Teks (opsional jika ada gambar)'),
            hint:
                'Tempel atau ketik teks yang ingin diterjemahkan / dijelaskan',
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
                  onPress: submitting.value || !isAuth
                      ? null
                      : pasteClipboard,
                  prefix: const Icon(FLucideIcons.clipboardPaste, size: 14),
                  child: const Text('Tempel'),
                ),
                const Gap(4),
                Text(
                  '${trimmed.length}/1000',
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (attachmentsEnabled.value) ...[
            const Gap(8),
            Text(
              'Foto (opsional, maks 4)',
              style: context.theme.typography.sm.copyWith(
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
              disabledHint: 'Masuk untuk lampirkan foto.',
              disabledActionLabel: 'Masuk',
              onDisabledAction: promptLogin,
              onUnavailable: () {
                attachmentsEnabled.value = false;
                images.value = const [];
              },
              upload: (File file, {required bool isPrimary}) async {
                final uploader = ref.read(
                  translationHelpImageUploadServiceProvider,
                );
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
                    const AttachmentUploadFailure(
                      'Satu gambar gagal diunggah',
                    ),
                  );
                } catch (_) {
                  return Either.left(
                    const AttachmentUploadFailure(
                      'Satu gambar gagal diunggah',
                    ),
                  );
                }
              },
            ),
          ],
          if (errorMessage.value != null) ...[
            const Gap(12),
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(errorMessage.value!),
            ),
          ],
          const Gap(16),
          FButton(
            onPress: canSubmit
                ? () => submit()
                : (!isAuth ? promptLogin : null),
            prefix: submitting.value ? const FCircularProgress() : null,
            child: Text(submitting.value ? 'Mengirim...' : 'Kirim'),
          ),
        ],
      ),
    );
  }
}

String _mapDio(DioException error) {
  final data = error.response?.data;
  if (data is Map &&
      data['message'] is String &&
      (data['message'] as String).isNotEmpty) {
    final message = data['message'] as String;
    if (error.response?.statusCode == 429) {
      final retry = error.response?.headers.value('retry-after');
      if (retry != null && retry.isNotEmpty) {
        return '$message Coba lagi dalam $retry detik.';
      }
    }
    return message;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'Koneksi lambat, coba lagi',
    DioExceptionType.connectionError => 'Tidak ada koneksi internet',
    _ => 'Terjadi kesalahan, coba lagi',
  };
}
