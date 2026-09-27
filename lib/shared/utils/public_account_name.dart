/// Sama dengan `DELETED_ACCOUNT_LABEL` di API. Bukan username yang bisa dibuka.
const deletedAccountLabel = 'Akun tidak ditemukan';

bool isLinkablePublicUsername(String? username) {
  if (username == null || username.isEmpty) return false;
  if (username == 'anonim' || username == deletedAccountLabel) return false;
  if (username.startsWith('dihapus-')) return false;
  return true;
}

String displayPublicUsername(String? username) {
  if (username == null || username.isEmpty || username.startsWith('dihapus-')) {
    return deletedAccountLabel;
  }
  return username;
}

/// Label orang di UI: prefer [displayName], fallback [username].
String displayPublicAccountLabel({
  String? displayName,
  String? username,
}) {
  final trimmed = displayName?.trim();
  if (trimmed != null &&
      trimmed.isNotEmpty &&
      trimmed != deletedAccountLabel &&
      !trimmed.startsWith('dihapus-')) {
    return trimmed;
  }
  return displayPublicUsername(username);
}
