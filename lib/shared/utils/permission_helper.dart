import 'dart:io';

import 'package:flutter/material.dart';
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
  showDialog<void>(
    context: context,
    builder: (innerContext) {
      return AlertDialog(
        title: const Text('Izin Ditolak'),
        content: const Text(
            'Biar fitur ini jalan, izinkan akses '
            'ke galeri atau kamera dari pengaturan aplikasi.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(innerContext).pop(),
          ),
          TextButton(
            child: const Text('Pengaturan'),
            onPressed: () {
              openAppSettings();
              Navigator.of(innerContext).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Dialog khusus saat izin mikrofon ditolak permanen (buka Pengaturan).
void showMicrophonePermissionDeniedDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (innerContext) {
      return AlertDialog(
        title: const Text('Izin mikrofon diperlukan'),
        content: const Text(
          'Akses mikrofon dimatikan untuk SambasKu. Aktifkan di Pengaturan '
          'perangkat agar bisa merekam pelafalan kata.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(innerContext).pop(),
          ),
          TextButton(
            child: const Text('Pengaturan'),
            onPressed: () {
              openAppSettings();
              Navigator.of(innerContext).pop();
            },
          ),
        ],
      );
    },
  );
}
