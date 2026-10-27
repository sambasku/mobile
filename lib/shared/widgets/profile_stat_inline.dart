import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Baris "angka label" stat profil ala feed: count bold + label muted,
/// dipisah titik tengah. Dipakai tab Profil + profil publik.
class ProfileStatInline extends StatelessWidget {
  const ProfileStatInline({
    super.key,
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$count',
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titik pemisah antar item stat.
class ProfileStatDot extends StatelessWidget {
  const ProfileStatDot({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Text(
      '·',
      style: context.theme.typography.body.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
  );
}

/// Baris ringkas stat profil: `3 usul kata · 2 perbaikan`.
///
/// Satu baris, dua angka yang benar-benar dicari orang. Hitungan lain
/// (verifikasi, komentar, kontribusi) sengaja tidak ditampilkan - "kontribusi"
/// = turunan dari dua angka ini, sisanya noise di header profil.
class ProfileStatRow extends StatelessWidget {
  const ProfileStatRow({
    super.key,
    required this.words,
    required this.corrections,
  });

  final int words;
  final int corrections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 2,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ProfileStatInline(count: words, label: 'usul kata'),
        const ProfileStatDot(),
        ProfileStatInline(count: corrections, label: 'perbaikan'),
      ],
    );
  }
}

/// Meta profil: "Bergabung tanggal".. Centang verifikator TIDAK di sini -
/// sudah ada di samping nama ([PublicAccountName]); dulu ikut tampil di
/// baris ini sehingga terlihat centang dobel.
class ProfileMetaRow extends StatelessWidget {
  const ProfileMetaRow({super.key, required this.joinedLabel});

  final String joinedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (joinedLabel.trim().isEmpty) return const SizedBox.shrink();
    return Text(
      'Bergabung $joinedLabel',
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
}
