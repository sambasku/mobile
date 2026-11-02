import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../../l10n/app_localizations.dart';

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
    title: AppLocalizations.of(context).discussionReplyRecordTitle,
    subtitle: AppLocalizations.of(context).discussionReplyRecordSubtitle,
    submitLabel: AppLocalizations.of(context).discussionReplyRecordSubmit,
    onSubmit: onSubmit,
  );
}
