import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/image_attribution.dart';
import '../utils/image_sheet_drawer.dart';
import 'cached_network_image_with_fallback.dart';
import 'image_credit.dart';

/// Hasil upload CDN ATAU referensi stock Media Explorer.
class AttachmentUploadedImage {
  const AttachmentUploadedImage({
    required this.url,
    required this.providerFileId,
    this.provider,
    this.sha,
    this.altText,
    this.isPrimary = false,
    this.contentWarnings = const [],
    this.attribution,
  });

  final String url;
  final String providerFileId;
  /// Stock: pexels|pixabay|… ; upload GitHub: null (diisi API).
  final String? provider;
  final String? sha;
  final String? altText;
  final bool isPrimary;
  /// Peringatan konten yang dipilih oleh kontributor. V1: 'kekerasan'.
  final List<String> contentWarnings;
  /// Kredit foto stock Media Explorer; upload kamera/galeri: null.
  final ImageAttribution? attribution;
}

/// Gagal upload lampiran (token/CDN/jaringan).
class AttachmentUploadFailure {
  const AttachmentUploadFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}

/// Slot lokal + status upload (upload segera setelah pilih).
/// Stock Media Explorer: [localPath] kosong, [uploaded] langsung terisi.
class AttachmentImageSlot {
  const AttachmentImageSlot({
    required this.id,
    required this.localPath,
    this.uploaded,
    this.uploading = false,
    this.error = false,
    this.contentWarnings = const [],
  });

  final String id;
  final String localPath;
  final AttachmentUploadedImage? uploaded;
  final bool uploading;
  final bool error;
  /// Peringatan konten dipilih oleh kontributor (mis. ['kekerasan']).
  final List<String> contentWarnings;

  bool get isReady => uploaded != null && !uploading && !error;
  bool get isNetworkOnly => localPath.isEmpty && uploaded != null;
  bool get hasViolenceWarning => contentWarnings.contains('kekerasan');

  AttachmentImageSlot copyWith({
    AttachmentUploadedImage? uploaded,
    bool? uploading,
    bool? error,
    bool clearUploaded = false,
    List<String>? contentWarnings,
  }) {
    return AttachmentImageSlot(
      id: id,
      localPath: localPath,
      uploaded: clearUploaded ? null : (uploaded ?? this.uploaded),
      uploading: uploading ?? this.uploading,
      error: error ?? this.error,
      contentWarnings: contentWarnings ?? this.contentWarnings,
    );
  }
}

typedef AttachmentUploadFn =
    Future<Either<AttachmentUploadFailure, AttachmentUploadedImage>> Function(
      File file, {
      required bool isPrimary,
    });

/// Field lampiran gambar kanonik (mobile-base-stack §9.1).
///
/// Forui + sheet Kamera/Galeri/(Media Explorer) + upload segera + overlay.
/// Token/folder di-inject lewat [upload] per fitur.
class AttachmentImagesField extends StatefulWidget {
  const AttachmentImagesField({
    super.key,
    required this.images,
    required this.onChanged,
    required this.upload,
    this.enabled = true,
    this.allowLocalPick = true,
    this.maxImages = 3,
    this.maxSizeMb = 5,
    this.disabledHint =
        'Masuk untuk lampirkan gambar (opsional).',
    this.disabledActionLabel,
    this.onDisabledAction,
    this.onUnavailable,
    /// Buka Media Explorer (foto stock). Null = opsi Explorer disembunyikan.
    this.onPickStockImage,
  });

  final bool enabled;
  /// Kamera/galeri (butuh upload CDN). False = hanya Media Explorer bila ada.
  final bool allowLocalPick;
  final int maxImages;
  final int maxSizeMb;
  final List<AttachmentImageSlot> images;
  final ValueChanged<List<AttachmentImageSlot>> onChanged;
  final AttachmentUploadFn upload;

  /// Saat [enabled] false: teks + opsional CTA (mis. Masuk).
  final String disabledHint;
  final String? disabledActionLabel;
  final VoidCallback? onDisabledAction;

  /// Dipanggil sekali saat `IMAGE_UPLOAD_UNAVAILABLE` (UI sembunyikan field).
  final VoidCallback? onUnavailable;

  /// Return null jika user batal; selain itu slot stock langsung `done`.
  final Future<AttachmentUploadedImage?> Function()? onPickStockImage;

  @override
  State<AttachmentImagesField> createState() => _AttachmentImagesFieldState();
}

class _AttachmentImagesFieldState extends State<AttachmentImagesField> {
  final _picker = ImagePicker();
  bool _unavailable = false;

  void _openPicker() {
    if (!widget.enabled || _unavailable) return;
    if (widget.images.length >= widget.maxImages) {
      _toast('Maksimal ${widget.maxImages} gambar');
      return;
    }

    // Tamu / tanpa upload lokal: langsung Media Explorer (tanpa sheet kamera).
    if (!widget.allowLocalPick) {
      if (widget.onPickStockImage != null) {
        _handleStockPick();
        return;
      }
      _toast('Masuk untuk lampirkan dari kamera atau galeri');
      return;
    }

    showImageSheetDrawer(
      context,
      picker: _picker,
      filePicker: false,
      mediaExplorerPicker: widget.onPickStockImage != null,
      onMediaExplorer: widget.onPickStockImage == null
          ? null
          : () {
              _handleStockPick();
            },
      onPicked: _handlePicked,
      onRemoved: () {
        widget.onChanged(const []);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handleStockPick() async {
    final pick = widget.onPickStockImage;
    if (pick == null || !mounted) return;
    if (widget.images.length >= widget.maxImages) {
      _toast('Maksimal ${widget.maxImages} gambar');
      return;
    }

    final uploaded = await pick();
    if (!mounted || uploaded == null) return;
    if (widget.images.length >= widget.maxImages) {
      _toast('Maksimal ${widget.maxImages} gambar');
      return;
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final isPrimary = widget.images.isEmpty;
    final slot = AttachmentImageSlot(
      id: id,
      localPath: '',
      uploaded: AttachmentUploadedImage(
        url: uploaded.url,
        providerFileId: uploaded.providerFileId,
        provider: uploaded.provider,
        sha: uploaded.sha,
        altText: uploaded.altText,
        isPrimary: isPrimary,
        attribution: uploaded.attribution,
      ),
    );
    widget.onChanged([...widget.images, slot]);
  }

  Future<void> _handlePicked(File file) async {
    if (!mounted) return;
    if (widget.images.length >= widget.maxImages) {
      _toast('Maksimal ${widget.maxImages} gambar');
      return;
    }

    try {
      final size = await file.length();
      if (size > widget.maxSizeMb * 1024 * 1024) {
        if (mounted) _toast('Gambar melebihi ${widget.maxSizeMb} MB');
        return;
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final isPrimary = widget.images.isEmpty;
      final slot = AttachmentImageSlot(
        id: id,
        localPath: file.path,
        uploading: true,
      );
      final afterAdd = [...widget.images, slot];
      widget.onChanged(afterAdd);
      await _upload(id, file, isPrimary: isPrimary, afterAdd: afterAdd);
    } catch (e) {
      debugPrint('[AttachmentImages] handle $e');
      if (mounted) _toast('Gagal memproses gambar');
    }
  }

  Future<void> _upload(
    String id,
    File file, {
    required bool isPrimary,
    required List<AttachmentImageSlot> afterAdd,
  }) async {
    final result = await widget.upload(file, isPrimary: isPrimary);
    if (!mounted) return;

    result.match(
      (failure) {
        if (failure.errorCode == 'IMAGE_UPLOAD_UNAVAILABLE') {
          setState(() => _unavailable = true);
          widget.onUnavailable?.call();
        }
        _patch(
          id,
          (s) => s.copyWith(uploading: false, error: true, clearUploaded: true),
          afterAdd: afterAdd,
        );
        _toast(failure.message);
      },
      (uploaded) {
        _patch(
          id,
          (s) => s.copyWith(uploading: false, error: false, uploaded: uploaded),
          afterAdd: afterAdd,
        );
      },
    );
  }

  /// Gabungkan list parent terkini dengan [afterAdd] supaya slot baru tidak
  /// hilang jika parent belum rebuild, dan slot paralel tidak tertimpa.
  List<AttachmentImageSlot> _baseForPatch(
    String id,
    List<AttachmentImageSlot> afterAdd,
  ) {
    final current = widget.images;
    if (current.any((e) => e.id == id)) return current;
    final seen = {for (final s in current) s.id};
    return [
      ...current,
      for (final s in afterAdd)
        if (!seen.contains(s.id)) s,
    ];
  }

  void _patch(
    String id,
    AttachmentImageSlot Function(AttachmentImageSlot) map, {
    required List<AttachmentImageSlot> afterAdd,
  }) {
    final base = _baseForPatch(id, afterAdd);
    widget.onChanged([
      for (final img in base)
        if (img.id == id) map(img) else img,
    ]);
  }

  void _remove(String id) {
    widget.onChanged([
      for (final img in widget.images)
        if (img.id != id) img,
    ]);
  }

  void _toggleViolence(String id) {
    widget.onChanged([
      for (final img in widget.images)
        if (img.id == id)
          img.copyWith(
            contentWarnings: img.hasViolenceWarning
                ? img.contentWarnings
                      .where((w) => w != 'kekerasan')
                      .toList(growable: false)
                : [...img.contentWarnings, 'kekerasan'],
          )
        else
          img,
    ]);
  }

  void _toast(String message) {
    showFToast(
      context: context,
      title: Text(message),
      variant: FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (!widget.enabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.disabledHint,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          if (widget.disabledActionLabel != null &&
              widget.onDisabledAction != null) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: widget.onDisabledAction,
              child: Text(widget.disabledActionLabel!),
            ),
          ],
        ],
      );
    }

    if (_unavailable) {
      return Text(
        'Upload gambar sementara tidak tersedia. Formulir tetap bisa dikirim tanpa gambar.',
        style: theme.typography.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }

    final hintParts = <String>[
      if (widget.allowLocalPick) 'Kamera/galeri',
      if (widget.onPickStockImage != null) 'Media Explorer',
      if (widget.allowLocalPick) 'maks ${widget.maxSizeMb} MB',
      'hingga ${widget.maxImages}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.images.length; i++) ...[
          _Thumb(
            slot: widget.images[i],
            onRemove: () => _remove(widget.images[i].id),
            onViolenceToggle: () => _toggleViolence(widget.images[i].id),
          ),
          if (i != widget.images.length - 1)
            Divider(height: 16, color: theme.colors.border),
        ],
        if (widget.images.isNotEmpty &&
            widget.images.length < widget.maxImages)
          const Gap(8),
        if (widget.images.length < widget.maxImages)
          FButton(
            variant: FButtonVariant.outline,
            onPress: _openPicker,
            prefix: const Icon(FLucideIcons.imagePlus, size: 14),
            child: Text(
              widget.allowLocalPick ? 'Tambah' : 'Pilih dari Media Explorer',
            ),
          ),
        const Gap(4),
        Text(
          hintParts.join(' · '),
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.slot,
    required this.onRemove,
    required this.onViolenceToggle,
  });

  final AttachmentImageSlot slot;
  final VoidCallback onRemove;
  final VoidCallback onViolenceToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final networkUrl = slot.uploaded?.url;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: slot.localPath.isNotEmpty
                      ? Image.file(
                          File(slot.localPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colors.muted,
                            child: Icon(
                              FLucideIcons.image,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        )
                      : (networkUrl != null && networkUrl.isNotEmpty)
                      ? CachedNetworkImageWithFallback(
                          imageUrl: networkUrl,
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            FLucideIcons.image,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                ),
              ),
              if (slot.uploading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x88000000),
                    child: Center(child: FCircularProgress()),
                  ),
                ),
              if (slot.error)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0x88B91C1C),
                    child: Icon(
                      FLucideIcons.circleAlert,
                      color: theme.colors.primaryForeground,
                      size: 20,
                    ),
                  ),
                ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.colors.destructive,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FLucideIcons.x,
                      size: 12,
                      color: theme.colors.primaryForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Checkbox kekerasan di kanan thumb - hanya setelah upload siap.
        if (slot.isReady) ...[
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FCheckbox(
                  value: slot.hasViolenceWarning,
                  label: Text(
                    'Foto berisi kekerasan',
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  onChange: (_) => onViolenceToggle(),
                ),
                const Gap(2),
                Text(
                  'Centang kalau fotonya menunjukkan kekerasan (misalnya luka, darah, atau senjata yang dipakai menyerang). Tim kami juga bisa menandai ini nanti.',
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
                if (slot.uploaded?.attribution case final credit?) ...[
                  const Gap(6),
                  ImageCredit(attribution: credit, fontSize: 11),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Slot siap → daftar `{url, providerFileId}` generik.
List<AttachmentUploadedImage> readyAttachmentImages(
  List<AttachmentImageSlot> slots,
) {
  return [
    for (final s in slots)
      if (s.isReady && s.uploaded != null) s.uploaded!,
  ];
}
