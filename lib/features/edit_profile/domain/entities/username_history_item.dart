class UsernameHistoryItem {
  const UsernameHistoryItem({
    required this.oldUsername,
    required this.newUsername,
    required this.changedAt,
    required this.holdUntil,
    required this.canReclaim,
  });

  final String oldUsername;
  final String newUsername;
  final DateTime changedAt;
  final DateTime holdUntil;
  final bool canReclaim;
}
