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
    final linkTrimmed =
        shareSocialLink.value ? link.text.trim() : '';
    final canSubmit = isAuth && trimmed.isNotEmpty && !submitting.value;

    void promptLogin() {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk memulai diskusi'),
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

    Future<void> pickAudio() async {
      if (!isAuth || submitting.value) {
        if (!isAuth) promptLogin();
        return;
      }
      final recorded = await showRecordThreadAudioSheet(
        context,
        title: 'Rekam untuk diskusi',
        subtitle:
            'Maksimal 60 detik. Rekaman dilampirkan setelah deskripsi dikirim.',
        submitLabel: 'Pakai rekaman',
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
          title: const Text('Tunggu upload gambar selesai'),
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
              message: 'Deskripsi wajib diisi',
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
                message: 'Tautan harus memakai https://',
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
          body: trimmed,
          linkUrl: linkTrimmed.isEmpty ? null : linkTrimmed,
          images: [
            for (final u in ready)
              DiscussionImageRef(
                url: u.url,
                providerFileId: u.providerFileId,
              ),
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
                ? 'Diskusi terkirim; rekaman gagal dilampirkan'
                : 'Permintaan terkirim, menunggu pengecekan',
          ),
        );
        context.pushReplacement(DiscussionRouter.detailPath(result.id));
      } on DioException catch (e) {
        if (context.mounted) {
          await showAppErrorSheet(context, message: _mapDio(e));
        }
      } on ImageUploadUnavailable {
        if (context.mounted) {
          await showAppErrorSheet(
            context,
            message: 'Penyimpanan gambar belum tersedia',
          );
        }
      } catch (_) {
        if (context.mounted) {
          await showAppErrorSheet(
            context,
            message: 'Terjadi kesalahan, coba lagi',
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
        title: const Text('Mulai Diskusi'),
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
          const FAlert(
            icon: Icon(FLucideIcons.info),
            title: Text('Diperiksa tim sebelum tayang'),
            subtitle: Text(
              'Tulis deskripsi (wajib). Foto dan suara opsional. Setelah disetujui, threadmu tampil dan warga bisa membalas.',
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
            focusNode: bodyFocus,
            enabled: !submitting.value && isAuth,
            label: const Text('Deskripsi'),
            hint: 'Jelaskan pertanyaan atau konteks bahasa yang ingin didiskusikan',
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
                    'Aku ingin membagikan link dari sosial media',
                    style: context.theme.typography.sm.copyWith(
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
              label: const Text('Tautan'),
              hint: 'https://… dari Instagram, TikTok, YouTube, dll.',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
          ],
          const Gap(12),
          Text(
            'Rekam suara (opsional)',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          if (audio != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rekaman siap · ${audioSec}s',
                    style: context.theme.typography.sm,
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: submitting.value ? null : clearAudio,
                  child: const Text('Hapus'),
                ),
                const Gap(4),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: submitting.value || !isAuth ? null : pickAudio,
                  prefix: const Icon(FLucideIcons.mic, size: 14),
                  child: const Text('Ulangi'),
                ),
              ],
            )
          else
            FButton(
              variant: FButtonVariant.outline,
              onPress: submitting.value || !isAuth ? null : pickAudio,
              prefix: const Icon(FLucideIcons.mic, size: 14),
              child: const Text('Rekam suara'),
            ),
          if (attachmentsEnabled.value) ...[
            const Gap(12),
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
                  discussionImageUploadServiceProvider,
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
