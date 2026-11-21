import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../shared/utils/public_account_name.dart';

/// Lemma kartu Periksa / riwayat: bedakan terjemahan vs definisi (selaras
/// baris terjemahan di detail kata).
class PeriksaMeaningBlurb extends StatelessWidget {
  const PeriksaMeaningBlurb({
    super.key,
    required this.translation,
    required this.definition,
  });

  final String translation;
  final String definition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (translation.isNotEmpty) ...[
          const Gap(2),
          Text(
            '→ $translation',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
        if (definition.isNotEmpty) ...[
          const Gap(3),
          Text(
            definition,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

/// Baris lemma + nama pengusul makna (kanan atas).
class PeriksaLemmaHeader extends StatelessWidget {
  const PeriksaLemmaHeader({
    super.key,
    required this.lemma,
    this.contributorUsername,
    this.contributorDisplayName,
  });

  final String lemma;
  final String? contributorUsername;
  final String? contributorDisplayName;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = displayPublicAccountLabel(
      displayName: contributorDisplayName,
      username: contributorUsername,
    );
    final showContributor =
        label != deletedAccountLabel &&
        ((contributorUsername != null && contributorUsername!.isNotEmpty) ||
            (contributorDisplayName != null &&
                contributorDisplayName!.trim().isNotEmpty));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            lemma,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showContributor) ...[
          const Gap(6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.user,
                size: 12,
                color: theme.colors.mutedForeground,
              ),
              const Gap(3),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 92),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
