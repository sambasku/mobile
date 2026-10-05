import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

/// Izin tambah ke galeri (foto atau video). False jika user menolak.
Future<bool> requestGalleryWriteAccess() async {
  if (await Gal.hasAccess()) return true;
  if (await Gal.requestAccess()) return true;
  final perm = Platform.isIOS ? Permission.photosAddOnly : Permission.photos;
  final status = await perm.request();
  if (status.isGranted || status.isLimited) return true;
  return Gal.hasAccess();
}

void showPermissionDeniedDialog(BuildContext context) {
  showModalBottomSheet<void>(
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
                title: const Text('Izin Ditolak'),
                subtitle: const Text('Biar fitur ini jalan, izinkan akses ke galeri atau kamera dari pengaturan aplikasi.'),
              ),
              FTile(
                title: const Text(''),
                suffix: FButton(
                  onPress: () {
                    openAppSettings();
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Pengaturan'),
                ),
              ),
              FTile(
                title: const Text(''),
                suffix: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Dialog khusus saat izin mikrofon ditolak permanen (buka Pengaturan).
void showMicrophonePermissionDeniedDialog(BuildContext context) {
  showModalBottomSheet<void>(
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
                title: const Text('Izin mikrofon diperlukan'),
                subtitle: const Text('Akses mikrofon dimatikan untuk SambasKu. Aktifkan di Pengaturan perangkat agar bisa merekam pelafalan kata.'),
              ),
              FTile(
                title: const Text(''),
                suffix: FButton(
                  onPress: () {
                    openAppSettings();
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Pengaturan'),
                ),
              ),
              FTile(
                title: const Text(''),
                suffix: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
