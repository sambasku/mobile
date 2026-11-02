import '../../../l10n/app_localizations.dart';
import '../domain/sambas_map_config.dart';

/// Label jenis pengajuan kuliner (kode wire API -> teks UI).
String culinaryKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'new_cuisine' => l10n.culinaryKindNewCuisine,
  'new_place' => l10n.culinaryKindNewPlace,
  'cuisine_edit' => l10n.culinaryKindCuisineEdit,
  'place_edit' => l10n.culinaryKindPlaceEdit,
  'link' || 'link_edit' => l10n.culinaryKindLink,
  'place_operational' => l10n.culinaryKindOperational,
  'archive' => l10n.culinaryKindArchive,
  'restore' => l10n.culinaryKindRestore,
  _ => '',
};

/// Label status pengajuan kuliner.
///
/// Reuse key `usahaStatus*`: teks status ("Menunggu", "Disetujui", ...) sama
/// untuk semua antrean usulan, tidak perlu key keempat.
String culinaryStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'approved' => l10n.usahaStatusApproved,
      'rejected' => l10n.usahaStatusRejected,
      'needs_revision' => l10n.usahaStatusNeedsRevision,
      _ => l10n.usahaStatusPending,
    };

/// Alasan penolakan: `kode: teks server`, atau label kode saja.
String culinaryRejectDisplay(
  AppLocalizations l10n, {
  required String? code,
  required String? text,
}) {
  final trimmed = text?.trim();
  final hasText = trimmed != null && trimmed.isNotEmpty;
  if (code == null || code.isEmpty) return hasText ? trimmed : '';
  final label = switch (code) {
    'duplicate' => l10n.culinaryRejectDuplicate,
    'incomplete' => l10n.culinaryRejectIncomplete,
    'invalid' => l10n.culinaryRejectInvalid,
    'unverifiable' => l10n.culinaryRejectUnverifiable,
    'attribution' => l10n.culinaryRejectAttribution,
    'violation' => l10n.culinaryRejectViolation,
    'stale' => l10n.culinaryRejectStale,
    _ => l10n.culinaryRejectOther,
  };
  return hasText ? '$label: $trimmed' : label;
}

/// Label status operasional tempat kuliner.
String culinaryOperationalLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'operating' => l10n.culinaryStatusOperating,
      'temporarily_closed' => l10n.culinaryStatusTemporarilyClosed,
      'permanently_closed' => l10n.culinaryStatusPermanentlyClosed,
      _ => l10n.culinaryStatusUnknown,
    };

/// Label basemap peta.
String mapBasemapLabel(AppLocalizations l10n, MapBasemap basemap) =>
    switch (basemap) {
      MapBasemap.street => l10n.exploreMapStyleStreet,
      MapBasemap.satellite => l10n.exploreMapStyleSatellite,
      MapBasemap.terrain => l10n.exploreMapStyleTerrain,
    };

/// Kode alasan laporan tempat/kuliner (urutan tampil).
const culinaryReportReasons = <String>[
  'closed',
  'wrong_location',
  'invalid_contact',
  'misleading',
  'duplicate',
  'abuse',
];

/// Label alasan laporan tempat/kuliner.
String culinaryReportReasonLabel(AppLocalizations l10n, String code) =>
    switch (code) {
      'closed' => l10n.culinaryReasonClosed,
      'wrong_location' => l10n.culinaryReasonWrongLocation,
      'invalid_contact' => l10n.culinaryReasonInvalidContact,
      'misleading' => l10n.culinaryReasonMisleading,
      'duplicate' => l10n.culinaryReasonDuplicate,
      _ => l10n.culinaryReasonAbuse,
    };
