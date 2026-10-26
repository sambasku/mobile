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

/// Grid stat profil 5 angka (3 kolom): usul kata, perbaikan, verifikasi,
/// komentar, kontribusi. Dipakai header identitas dua halaman profil.
///
/// Angka 0 tetap ditampilkan (muted) supaya profil baru tidak terlihat
/// kosong - bukan sinyal "belum ada kontribusi".
class ProfileStatGrid extends StatelessWidget {
  const ProfileStatGrid({
    super.key,
    required this.words,
    required this.corrections,
    required this.verifications,
    required this.comments,
    required this.contributions,
    this.compact = false,
  });

  final int words;
  final int corrections;
  final int verifications;
  final int comments;
  final int contributions;

  /// true = tipografi satu tingkat lebih kecil (header compact).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final numberStyle = (compact
            ? theme.typography.body.md
            : theme.typography.body.lg)
        .copyWith(fontWeight: FontWeight.w700, height: 1.15);
    final labelStyle = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      height: 1.2,
    );

    final entries = <({int count, String label})>[
      (count: words, label: 'usul kata'),
      (count: corrections, label: 'perbaikan'),
      (count: verifications, label: 'verifikasi'),
      (count: comments, label: 'komentar'),
      (count: contributions, label: 'kontribusi'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 kolom saat ruang cukup, 2 kolom saat sempit (layar kecil + font
        // besar). Tidak pakai GridView: 5 item butuh baris terakhir rata kiri
        // tanpa sisa sel kosong yang ikut memakan tinggi.
        const gap = 8.0;
        final columns = constraints.maxWidth < 240 ? 2 : 3;
        final cellWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 10,
          children: [
            for (final entry in entries)
              SizedBox(
                width: cellWidth,
                child: Semantics(
                  label: '${entry.count} ${entry.label}',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${entry.count}', style: numberStyle),
                      Text(entry.label, style: labelStyle),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Baris lengkap 2 stat profil: usul kata · perbaikan.
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
