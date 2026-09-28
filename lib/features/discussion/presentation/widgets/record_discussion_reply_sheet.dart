import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/record_thread_audio_sheet.dart';

/// Sheet rekam balasan suara Ruang Diskusi (tanpa dialek / nama penutur).
Future<void> showRecordDiscussionReplySheet(
  BuildContext context, {
  required Future<String?> Function({
    required File audioFile,
    required int durationMs,
  }) onSubmit,
}) async {
  await showRecordThreadAudioSheet(
    context,
    title: 'Rekam balasan suara',
    subtitle:
        'Maksimal 60 detik. Caption teks bisa ditambahkan di kolom balasan sebelum merekam.',
    submitLabel: 'Kirim rekaman',
    onSubmit: onSubmit,
  );
}
