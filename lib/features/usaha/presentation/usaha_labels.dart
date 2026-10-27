import '../../../l10n/app_localizations.dart';
import '../domain/entities/usaha.dart';

/// Label status operasional usaha.
String usahaOperationalLabel(
  AppLocalizations l10n,
  UsahaOperationalStatus status,
) => switch (status) {
  UsahaOperationalStatus.unknown => l10n.usahaOperationalUnknown,
  UsahaOperationalStatus.open => l10n.usahaOperationalOpen,
  UsahaOperationalStatus.temporarilyClosed =>
    l10n.usahaOperationalTemporarilyClosed,
  UsahaOperationalStatus.permanentlyClosed =>
    l10n.usahaOperationalPermanentlyClosed,
};

/// Label jenis usaha.
String usahaKindLabel(AppLocalizations l10n, UsahaKind kind) => switch (kind) {
  UsahaKind.product => l10n.usahaKindProduct,
  UsahaKind.service => l10n.usahaKindService,
  UsahaKind.both => l10n.usahaKindBoth,
};

/// Label status pengajuan usaha.
String usahaContributionStatusLabel(
  AppLocalizations l10n,
  UsahaContributionStatus status,
) => switch (status) {
  UsahaContributionStatus.approved => l10n.usahaStatusApproved,
  UsahaContributionStatus.rejected => l10n.usahaStatusRejected,
  UsahaContributionStatus.needsRevision => l10n.usahaStatusNeedsRevision,
  UsahaContributionStatus.pending => l10n.usahaStatusPending,
};

/// Label status klaim pengelolaan.
String usahaClaimStatusLabel(AppLocalizations l10n, UsahaClaimStatus status) =>
    switch (status) {
      UsahaClaimStatus.approved => l10n.usahaStatusApproved,
      UsahaClaimStatus.rejected => l10n.usahaStatusRejected,
      UsahaClaimStatus.cancelled => l10n.usahaClaimStatusCancelled,
      UsahaClaimStatus.pending => l10n.usahaStatusPending,
    };

/// Label jenis pengajuan usaha.
String usahaContributionKindLabel(
  AppLocalizations l10n,
  UsahaContributionKind kind,
) => switch (kind) {
  UsahaContributionKind.baru => l10n.usahaKindNew,
  UsahaContributionKind.profile => l10n.usahaKindProfile,
  UsahaContributionKind.itemAdd => l10n.usahaKindItemAdd,
  UsahaContributionKind.itemEdit => l10n.usahaKindItemEdit,
  UsahaContributionKind.itemDelete => l10n.usahaKindItemDelete,
  UsahaContributionKind.operational => l10n.usahaKindOperational,
  UsahaContributionKind.archive => l10n.usahaKindArchive,
  UsahaContributionKind.restore => l10n.usahaKindRestore,
};

/// Label kode alasan penolakan usulan/klaim.
String usahaRejectCodeLabel(AppLocalizations l10n, String code) =>
    switch (code) {
      'duplicate' => l10n.usahaRejectDuplicate,
      'incomplete' => l10n.usahaRejectIncomplete,
      'invalid' => l10n.usahaRejectInvalid,
      'not_owner' => l10n.usahaRejectNotOwner,
      'stale' => l10n.usahaRejectStale,
      'violation' => l10n.usahaRejectViolation,
      'evidence_insufficient' => l10n.usahaRejectEvidenceInsufficient,
      'claim_conflict' => l10n.usahaRejectClaimConflict,
      _ => l10n.usahaRejectOther,
    };

/// Teks alasan penolakan siap tampil: `label: teks server`, atau salah satu.
String usahaRejectDisplay(
  AppLocalizations l10n, {
  required String? code,
  required String? text,
}) {
  final trimmed = text?.trim();
  final hasText = trimmed != null && trimmed.isNotEmpty;
  if (code == null) return hasText ? trimmed : l10n.usahaRejectDefault;
  final label = usahaRejectCodeLabel(l10n, code);
  return hasText ? '$label: $trimmed' : label;
}

/// Kode alasan laporan yang boleh dipilih user (urutan tampil).
const usahaReportReasonCodes = <String>[
  'closed',
  'wrong_location',
  'invalid_contact',
  'misleading',
  'duplicate',
  'abuse',
];

/// Label alasan laporan masyarakat.
String usahaReportReasonLabel(AppLocalizations l10n, String code) =>
    switch (code) {
      'closed' => l10n.usahaReportClosed,
      'wrong_location' => l10n.usahaReportWrongLocation,
      'invalid_contact' => l10n.usahaReportInvalidContact,
      'misleading' => l10n.usahaReportMisleading,
      'duplicate' => l10n.usahaReportDuplicate,
      _ => l10n.usahaReportAbuse,
    };
