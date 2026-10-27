import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../auth_router.dart';
import '../providers/auth_status_providers.dart';

/// Satu dokumen legal yang harus disetujui (versi aktif dari API).
typedef LegalConsentDoc = ({
  String documentType,
  String documentVersion,
  String title,
  String url,
});

/// Sheet persetujuan legal non-dismissible (tap luar / drag / back tidak
/// menutup). Muncul saat server bilang `requires_consent: true` - sumber
/// kebenaran GET /users/me, jadi force close tetap memunculkannya lagi.
///
/// Tutup satu-satunya jalan: "Setuju dan lanjut" (POST /accept-legal) atau
/// "Keluar" (logout). Forui FTileGroup, bukan AlertDialog (aturan repo).
///
/// Idempoten: pemanggil boleh memanggilnya dari build (post-frame) setiap
/// kali `requires_consent` true tanpa risiko sheet ganda.
///
/// Guard TIDAK pakai bool global yang di-release hanya setelah future
/// selesai - sheet bisa hilang tanpa pop (mis. navigasi paksa saat token
/// expired), future tak pernah selesai, guard mengunci selamanya dan
/// sheet tidak pernah muncul lagi. Guard dilepas saat widget sheet
/// di-dispose (sumber kebenaran: sheet benar-benar hilang dari tree).
final ValueNotifier<bool> _legalSheetOpen = ValueNotifier<bool>(false);

Future<void> showLegalConsentSheet(BuildContext context, WidgetRef ref) async {
  if (_legalSheetOpen.value) return;
  _legalSheetOpen.value = true;
  try {
    await _show(context, ref);
  } finally {
    _legalSheetOpen.value = false;
  }
}

/// Lepas guard saat sheet hilang dari tree (pop normal ATAU dihapus paksa).
class _ReleaseGuardOnDispose extends ConsumerStatefulWidget {
  const _ReleaseGuardOnDispose({required this.child});

  final Widget child;

  @override
  ConsumerState<_ReleaseGuardOnDispose> createState() =>
      _ReleaseGuardOnDisposeState();
}

class _ReleaseGuardOnDisposeState
    extends ConsumerState<_ReleaseGuardOnDispose> {
  @override
  void dispose() {
    _legalSheetOpen.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> _show(BuildContext context, WidgetRef ref) async {
  // Versi + URL dokumen aktif. Bisa gagal (offline) - sediakan retry,
  // jangan paksa user logout hanya karena jaringan.
  List<LegalConsentDoc>? docs;
  String? loadError;

  Future<void> loadVersions() async {
    try {
      final res = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>('/api/v1/legal/current');
      final data = res.data?['data'] as Map<String, dynamic>?;
      final terms = data?['terms'] as Map<String, dynamic>?;
      final privacy = data?['privacy'] as Map<String, dynamic>?;
      final termsVersion = terms?['version'] as String?;
      final privacyVersion = privacy?['version'] as String?;
      if (termsVersion != null && privacyVersion != null) {
        docs = [
          (
            documentType: 'terms',
            documentVersion: termsVersion,
            title: (terms?['title'] as String?) ?? 'Syarat dan Ketentuan',
            url: (terms?['url'] as String?) ?? AuthRouter.termsDocumentUrl,
          ),
          (
            documentType: 'privacy',
            documentVersion: privacyVersion,
            title: (privacy?['title'] as String?) ?? 'Kebijakan Privasi',
            url: (privacy?['url'] as String?) ?? AuthRouter.privacyDocumentUrl,
          ),
        ];
        loadError = null;
      } else {
        docs = null;
        loadError = 'Dokumen legal belum tersedia. Coba lagi sebentar.';
      }
    } catch (_) {
      docs = null;
      loadError = 'Gagal memuat dokumen legal. Coba lagi dalam beberapa saat.';
    }
  }

  await loadVersions();
  if (!context.mounted) return;

  var submitting = false;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) {
        Future<void> accept() async {
          final active = docs;
          if (active == null || submitting) return;
          setState(() => submitting = true);
          try {
            await ref
                .read(dioProvider)
                .post<Map<String, dynamic>>(
                  '/api/v1/auth/accept-legal',
                  data: {
                    'consents': [
                      for (final c in active)
                        {
                          'document_type': c.documentType,
                          'document_version': c.documentVersion,
                        },
                    ],
                    'client_id': 'sambasku-mobile',
                    'source': 'social_gate',
                  },
                );
            // Tunggu sinkronisasi server DULU (/users/me -> requires_consent
            // false), baru pop. Kalau pop dulu, dispose sheet melepas guard
            // dan post-frame trigger di shell langsung buka sheet kedua
            // (flicker) selama jeda invalidate.
            ref.invalidate(authStatusProvider);
            await ref.read(authStatusProvider.future);
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          } on DioException catch (error) {
            setState(() => submitting = false);
            if (!sheetContext.mounted) return;
            final data = error.response?.data;
            final message =
                (data is Map<String, dynamic> && data['message'] is String)
                ? data['message'] as String
                : 'Gagal menyimpan persetujuan. Coba lagi ya.';
            await showAppErrorSheet(sheetContext, message: message);
          }
        }

        final theme = sheetContext.theme;
        final loaded = docs;

        return _ReleaseGuardOnDispose(
          child: SafeArea(
            top: false,
            child: Padding(
              // viewInsets ikut di dalam padding supaya satu ritme:
              // kiri-kanan 20 (seragam info/error sheet), bukan full-bleed.
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SambasKu perlu izin kamu dulu',
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: .w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akun kamu dibuat lewat Google, GitHub, atau Facebook. '
                    'Sebelum lanjut, setujui dua dokumen di bawah - kami '
                    'pakai datamu hanya untuk menjalankan kamus ini.',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (loaded != null)
                    FTileGroup(
                      children: [
                        for (final doc in loaded)
                          FTile(
                            title: Text(doc.title),
                            subtitle: Text(
                              doc.documentType == 'terms'
                                  ? 'Aturan pakai SambasKu '
                                        '(versi ${doc.documentVersion})'
                                  : 'Data yang kami simpan dan cara kami '
                                        'menjaganya '
                                        '(versi ${doc.documentVersion})',
                            ),
                            suffix: FButton(
                              variant: FButtonVariant.outline,
                              onPress: () => context.push(
                                AuthRouter.legalDocument.path,
                                extra: (url: doc.url, title: doc.title),
                              ),
                              child: const Text('Baca'),
                            ),
                          ),
                      ],
                    )
                  else
                    FTileGroup(
                      children: [
                        FTile(
                          title: const Text('Dokumen belum bisa dimuat'),
                          subtitle: Text(
                            loadError ??
                                'Gagal memuat dokumen legal. Coba lagi dalam '
                                    'beberapa saat.',
                          ),
                          suffix: FButton(
                            variant: FButtonVariant.outline,
                            onPress: submitting
                                ? null
                                : () async {
                                    setState(() => submitting = true);
                                    await loadVersions();
                                    if (sheetContext.mounted) {
                                      setState(() => submitting = false);
                                    }
                                  },
                            child: const Text('Muat ulang'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamu bisa berhenti kapan saja dengan keluar dari akun.',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: loaded == null || submitting ? null : accept,
                    prefix: submitting ? const FCircularProgress() : null,
                    child: Text(
                      submitting ? 'Menyimpan...' : 'Setuju dan lanjut',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: submitting
                        ? null
                        : () async {
                            Navigator.of(sheetContext).pop();
                            await ref
                                .read(authStatusProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              context.go(AuthRouter.login.path);
                            }
                          },
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
