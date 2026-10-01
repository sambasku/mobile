import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../share/data/share_background_repository.dart';
import '../../../share/domain/share_models.dart';
import '../../../share/presentation/share_image_explorer_sheet.dart';
import '../../data/models/create_word_image_dto.dart';
import '../../data/providers/contribution_data_providers.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Alias agar pemanggil lama (suggest edit / contribute) tetap kompilasi.
typedef ContributeImageSlot = AttachmentImageSlot;

/// Field gambar usul kata - thin wrapper di atas [AttachmentImagesField]
/// (ImageKit staging `/words`, max 3, Media Explorer stock).
///
/// Tamu: [allowLocalPick] false → hanya Media Explorer (tanpa login).
/// Login: kamera/galeri + Explorer.
class ContributeImagesField extends ConsumerWidget {
  const ContributeImagesField({
    super.key,
    required this.enabled,
    required this.images,
    required this.onChanged,
    this.allowLocalPick = true,
  });

  final bool enabled;
  /// False = tamu: hanya stock Media Explorer (tanpa POST /images).
  final bool allowLocalPick;
  final List<AttachmentImageSlot> images;
  final ValueChanged<List<AttachmentImageSlot>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AttachmentImagesField(
      enabled: enabled,
      allowLocalPick: allowLocalPick,
      maxImages: 3,
      maxSizeMb: 5,
      images: images,
      onChanged: onChanged,
      disabledHint: allowLocalPick
          ? 'Masuk untuk lampirkan gambar (opsional).'
          : 'Pilih foto stock lewat Media Explorer (opsional).',
      disabledActionLabel: enabled || !allowLocalPick ? null : 'Masuk',
      onDisabledAction: enabled || !allowLocalPick
          ? null
          : () {
              context.push('/login');
            },
      onPickStockImage: () => _pickStockImage(context, ref),
      upload: (File file, {required bool isPrimary}) async {
        final service = ref.read(wordImageUploadServiceProvider);
        final result = await service.uploadFile(file, isPrimary: isPrimary);
        return result.match(
          (failure) => Either.left(
            AttachmentUploadFailure(
              failure.message,
              errorCode: failure.errorCode,
            ),
          ),
          (dto) => Either.right(
            AttachmentUploadedImage(
              url: dto.url,
              providerFileId: dto.providerFileId,
              provider: dto.provider ?? 'imagekit',
              sha: dto.sha,
              altText: dto.altText,
              isPrimary: dto.isPrimary,
            ),
          ),
        );
      },
    );
  }

  Future<AttachmentUploadedImage?> _pickStockImage(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selected = await showShareMediaExplorer(
      context,
      backgrounds: ShareBackgroundRepository(ref.read(dioProvider)),
      photoOnly: true,
    );
    if (selected == null || selected.kind != ShareMediaKind.photo) {
      return null;
    }
    final attribution = selected.attribution;
    return AttachmentUploadedImage(
      url: selected.url,
      providerFileId: selected.id,
      provider: selected.provider,
      altText: 'Foto: ${attribution.name} / ${selected.provider}',
      attribution: attribution,
    );
  }
}

/// Map slot siap → domain image untuk submit kata.
List<SubmitWordImage> readySubmitImages(List<AttachmentImageSlot> slots) {
  return [
    for (final s in slots)
      if (s.isReady && s.uploaded != null)
        SubmitWordImage(
          url: s.uploaded!.url,
          providerFileId: s.uploaded!.providerFileId,
          provider: s.uploaded!.provider,
          sha: s.uploaded!.sha,
          altText: s.uploaded!.altText,
          isPrimary: s.uploaded!.isPrimary,
          // contentWarnings diambil dari slot (dipilih user via checkbox),
          // bukan dari uploaded (respons server tidak menyertakannya).
          contentWarnings: List<String>.from(s.contentWarnings),
          attribution: s.uploaded!.attribution,
        ),
  ];
}

/// Bridge DTO lama (kalau dibutuhkan di luar wrapper).
CreateWordImageDto? contributeDtoOf(AttachmentImageSlot slot) {
  final u = slot.uploaded;
  if (u == null) return null;
  return CreateWordImageDto(
    url: u.url,
    providerFileId: u.providerFileId,
    provider: u.provider,
    sha: u.sha,
    altText: u.altText,
    isPrimary: u.isPrimary,
    attribution: u.attribution?.toJson(),
  );
}
