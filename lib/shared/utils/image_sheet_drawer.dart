import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_persist_helper.dart';
import 'compress_image_for_upload.dart';
import 'permission_helper.dart';
import 'photo_pick_constants.dart';

enum PhotoPickSource { camera, gallery, file, mediaExplorer }

/// Shows the "Pilih Sumber" bottom sheet.
void showImageSheetDrawer(
  BuildContext context, {
  ImagePicker? picker,
  Function(XFile image)? onImagePicked,
  Function(XFile image)? onCameraCaptured,
  Function(File image)? onFilePicked,
  Function(File image)? onPicked,
  Function(File image, PhotoPickSource source)? onPickedWithSource,
  Function()? onRemoved,
  /// Dipanggil setelah sheet ditutup - buka Media Explorer (stock).
  VoidCallback? onMediaExplorer,
  bool cameraPicker = true,
  bool galleryPicker = true,
  bool filePicker = true,
  bool mediaExplorerPicker = false,
  bool requireGpsForCamera = false,
  // Resize picker + post-pick WebP (mobile-base-stack §9.2).
  double maxWidth = kPhotoPickMaxWidth,
  double maxHeight = kPhotoPickMaxHeight,
  int imageQuality = kPhotoPickQuality,
}) {
  final imagePicker = picker ?? ImagePicker();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      // ponytail: Forui root sering tanpa Material; InkWell/IconButton butuhnya.
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Sumber',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // GridView di bottom sheet memicu assert semantics
                // ("Invisible SemanticsNodes…"); pakai Wrap 4 kolom.
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 8.0;
                    const columns = 4;
                    final cellWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    final buttons = <Widget>[
                      if (cameraPicker)
                        _SourceButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Kamera',
                          onTap: () => openCamera(
                            sheetContext,
                            imagePicker,
                            (xfile) {
                              final file = File(xfile.path);
                              onCameraCaptured?.call(xfile);
                              onPickedWithSource?.call(
                                file,
                                PhotoPickSource.camera,
                              );
                              onPicked?.call(file);
                            },
                            maxWidth: maxWidth,
                            maxHeight: maxHeight,
                            imageQuality: imageQuality,
                          ),
                        ),
                      if (galleryPicker)
                        _SourceButton(
                          icon: Icons.photo_outlined,
                          label: 'Galeri',
                          onTap: () => pickImageFromGallery(
                            sheetContext,
                            imagePicker,
                            (xfile) {
                              final file = File(xfile.path);
                              onImagePicked?.call(xfile);
                              onPickedWithSource?.call(
                                file,
                                PhotoPickSource.gallery,
                              );
                              onPicked?.call(file);
                            },
                            maxWidth: maxWidth,
                            maxHeight: maxHeight,
                            imageQuality: imageQuality,
                          ),
                        ),
                      if (filePicker)
                        _SourceButton(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'File',
                          onTap: () => pickImageFromFile(
                            sheetContext,
                            (file) {
                              onFilePicked?.call(file);
                              onPickedWithSource?.call(
                                file,
                                PhotoPickSource.file,
                              );
                              onPicked?.call(file);
                            },
                          ),
                        ),
                      if (mediaExplorerPicker && onMediaExplorer != null)
                        _SourceButton(
                          icon: Icons.travel_explore_outlined,
                          label: 'Explorer',
                          onTap: () {
                            // Pop dulu, baru buka Media Explorer setelah animasi
                            // sheet sumber selesai. Kalau showModal langsung di
                            // frame yang sama, sheet baru sering langsung hilang
                            // / hasil pilih jadi null.
                            Navigator.of(sheetContext).pop();
                            Future<void>.delayed(
                              const Duration(milliseconds: 300),
                              onMediaExplorer,
                            );
                          },
                        ),
                      _SourceButton(
                        icon: Icons.restart_alt,
                        label: 'Reset',
                        onTap: () => onRemoved?.call(),
                      ),
                    ];
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final button in buttons)
                          SizedBox(
                            width: cellWidth,
                            height: cellWidth * 0.95,
                            child: button,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> openCamera(
  BuildContext context,
  ImagePicker picker,
  Function(XFile) onSuccess, {
  double maxWidth = kPhotoPickMaxWidth,
  double maxHeight = kPhotoPickMaxHeight,
  int imageQuality = kPhotoPickQuality,
}) async {
  try {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) showPermissionDeniedDialog(context);
      return;
    }

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      // Intermediate hampir lossless; satu-satunya encode lossy di
      // compressImageForUpload.
      imageQuality: 100,
    );
    if (picked == null) return;

    final persisted = await copyToUniqueTempPath(File(picked.path));
    final compressed = await compressImageForUpload(
      persisted,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: imageQuality,
    );
    onSuccess(XFile(compressed.path));
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[Camera] $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka kamera')),
      );
    }
  }
}

Future<void> pickImageFromGallery(
  BuildContext context,
  ImagePicker picker,
  Function(XFile) onSuccess, {
  double maxWidth = kPhotoPickMaxWidth,
  double maxHeight = kPhotoPickMaxHeight,
  int imageQuality = kPhotoPickQuality,
}) async {
  try {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: 100,
    );
    if (picked == null) return;

    final persisted = await copyToUniqueTempPath(File(picked.path));
    final compressed = await compressImageForUpload(
      persisted,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: imageQuality,
    );
    onSuccess(XFile(compressed.path));
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[Gallery] $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih dari galeri')),
      );
    }
  }
}

Future<void> pickImageFromFile(
  BuildContext context,
  Function(File) onSuccess,
) async {
  try {
    final platformFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
    );
    if (platformFile == null) return;

    File source;
    final path = platformFile.path;
    if (path != null && path.isNotEmpty) {
      source = File(path);
    } else {
      final bytes = await platformFile.readAsBytes();
      if (bytes.isEmpty) return;
      final dir = await pickedPersistDir();
      source = File(
        '${dir.path}/pick_${DateTime.now().microsecondsSinceEpoch}_${platformFile.name}',
      );
      await source.writeAsBytes(bytes, flush: true);
    }

    final persisted = await copyToUniqueTempPath(source);
    // ponytail: flutter_image_compress memperlakukan min* sebagai batas sisi
    // pendek, jadi 4000x3000 jadi ~1600x1200 (kamera/galeri sudah di-cap
    // image_picker). Upgrade: hitung target sisi panjang sebelum compress.
    final compressed = await compressImageForUpload(persisted);
    onSuccess(compressed);
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[ImageSheet] file pick $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih file')),
      );
    }
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
