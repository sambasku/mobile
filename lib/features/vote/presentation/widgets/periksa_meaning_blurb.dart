import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

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

/// Baris lemma kartu Periksa / riwayat.
class PeriksaLemmaHeader extends StatelessWidget {
  const PeriksaLemmaHeader({
    super.key,
    required this.lemma,
  });

  final String lemma;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      lemma,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
