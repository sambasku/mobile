import '../../../l10n/app_localizations.dart';

/// Label jenis notifikasi. Domain hanya menyimpan nilai wire.
String notificationTypeLabel(AppLocalizations l10n, String type) =>
    switch (type) {
      'contribution_approved' || 'suggestion_approved' ||
      'verifier_application_approved' =>
        l10n.notificationTypeApproved,
      'contribution_rejected' || 'suggestion_rejected' ||
      'verifier_application_rejected' =>
        l10n.notificationTypeRejected,
      'contribution_corrected' || 'suggestion_corrected' =>
        l10n.notificationTypeCorrected,
      'word_taken_down' => l10n.notificationTypeTakenDown,
      'discussion_pending_review' => l10n.notificationTypeDiscussionPending,
      'discussion_approved' => l10n.notificationTypeDiscussionApproved,
      'discussion_rejected' => l10n.notificationTypeDiscussionRejected,
      'discussion_taken_down' => l10n.notificationTypeDiscussionTakenDown,
      'discussion_reply' => l10n.notificationTypeDiscussionReply,
      'discussion_mention' => l10n.notificationTypeDiscussionMention,
      'pantun_reply' => l10n.notificationTypePantunReply,
      'pantun_mention' => l10n.notificationTypePantunMention,
      'campaign' => l10n.notificationTypeCampaign,
      'word_comment' => l10n.notificationTypeComment,
      'word_vote' => l10n.notificationTypeVote,
      'word_example' => l10n.notificationTypeExample,
      'word_audio' => l10n.notificationTypeAudio,
      'place_contribution_approved' => l10n.notificationTypePlaceApproved,
      'place_contribution_rejected' => l10n.notificationTypePlaceRejected,
      'event_contribution_approved' => l10n.notificationTypeEventApproved,
      'event_contribution_rejected' => l10n.notificationTypeEventRejected,
      'event_contribution_needs_revision' =>
        l10n.notificationTypeEventNeedsRevision,
      _ => l10n.notificationTypeUpdate,
    };
