import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../core/models/speaker_status.dart';
import '../../l10n/app_localizations.dart';

/// Chip kecil di header profil: Penutur Sambas / Belajar Sambas.
class SpeakerStatusChip extends StatelessWidget {
  const SpeakerStatusChip({super.key, required this.status});

  final SpeakerStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final label = switch (status) {
      SpeakerStatus.native => l10n.profileSpeakerNative,
      SpeakerStatus.learner => l10n.profileSpeakerLearner,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.secondaryForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
