import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../auth_router.dart';
import '../providers/auth_status_providers.dart';

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
  // Versi dokumen aktif. Bisa gagal (offline) - sediakan retry, jangan
  // paksa user logout hanya karena jaringan.
  List<({String documentType, String documentVersion})>? consents;
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
        consents = [
          (documentType: 'terms', documentVersion: termsVersion),
          (documentType: 'privacy', documentVersion: privacyVersion),
        ];
        loadError = null;
      } else {
        consents = null;
        loadError = 'Dokumen legal belum tersedia. Coba lagi sebentar.';
      }
    } catch (_) {
      consents = null;
      loadError = 'Gagal memuat dokumen legal. Cek koneksi kamu ya.';
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
          final active = consents;
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

        return _ReleaseGuardOnDispose(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTileGroup(
                    label: const Text('Sebelum lanjut'),
                    children: [
                      FTile(
                        title: const Text('Setujui Syarat Ketentuan'),
                        subtitle: Text(
                          loadError ??
                              'Kami perlu persetujuan kamu untuk Syarat Ketentuan '
                                  'dan Kebijakan Privasi SambasKu. Baca dulu ya.',
                        ),
                        suffix: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () =>
                              context.push(AuthRouter.termsWebView.path),
                          child: const Text('Baca'),
                        ),
                      ),
                      if (loadError != null)
                        FTile(
                          title: const Text('Coba muat ulang'),
                          subtitle: const Text(
                            'Butuh koneksi untuk mengambil versi dokumen terbaru.',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        FButton(
                          onPress: consents == null || submitting
                              ? null
                              : accept,
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
