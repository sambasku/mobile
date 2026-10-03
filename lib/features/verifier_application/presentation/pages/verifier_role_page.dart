import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Halaman penjelasan peran verifikator (statis, tanpa API).
class VerifierRolePage extends StatelessWidget {
  const VerifierRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Peran verifikator'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/verifier-application'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          Text(
            'Baca ringkas apa itu verifikator dan apa saja yang dilakukan '
            'sebelum mengajukan diri.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(20),
          const _RoleBlock(
            title: 'Apa itu verifikator',
            body:
                'Verifikator adalah anggota komunitas yang memeriksa usulan '
                'kata warga sebelum entri dianggap terverifikasi di kamus. '
                'Peran ini menjaga arti, contoh, dan terjemahan tetap akurat.',
          ),
          const Gap(16),
          const _RoleBlock(
            title: 'Apa yang dilakukan',
            body:
                'Meninjau antrean kontribusi: menyetujui usulan yang tepat, '
                'menolak dengan alasan jika kurang layak, atau mengoreksi isi '
                'agar entri siap tayang. Keputusan itu menentukan apakah kata '
                'tampil sebagai Terverifikasi.',
          ),
          const Gap(16),
          const _RoleBlock(
            title: 'Yang tidak berubah',
            body:
                  'Kamu tetap bisa mengusulkan kata seperti biasa. Data kontak '
                'dan bukti sosial pada pengajuan tidak tampil di profil publik.',
          ),
          const Gap(16),
          const _RoleBlock(
            title: 'Data yang diminta saat ajukan',
            body:
                'Nomor HP dan alamat dipakai admin untuk menghubungi dan '
                'memastikan pemohon orang nyata dari komunitas. Username media '
                'sosial plus tangkapan layar membuktikan akun itu milik '
                'pemohon, bukan tautan kosong.',
          ),
          const Gap(16),
          const _RoleBlock(
            title: 'Setelah disetujui',
            body:
                  'Masuk ulang agar peran Verifikator aktif di aplikasi. Antrean '
                  'tinjau kemudian muncul di Profil. Kamu akan mendapat '
                  'notifikasi saat pengajuan diputuskan.',
          ),
        ],
      ),
    );
  }
}

class _RoleBlock extends StatelessWidget {
  const _RoleBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
