class UsernameHistoryItemDto {
  const UsernameHistoryItemDto({
    required this.oldUsername,
    required this.newUsername,
    required this.changedAt,
    required this.holdUntil,
    required this.canReclaim,
  });

  final String oldUsername;
  final String newUsername;
  final String changedAt;
  final String holdUntil;
  final bool canReclaim;

  factory UsernameHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return UsernameHistoryItemDto(
      oldUsername: json['old_username'] as String? ?? '',
      newUsername: json['new_username'] as String? ?? '',
      changedAt: json['changed_at'] as String? ?? '',
      holdUntil: json['hold_until'] as String? ?? '',
      canReclaim: json['can_reclaim'] as bool? ?? false,
    );
  }
}

class UsernameHistoryDto {
  const UsernameHistoryDto({required this.items});

  final List<UsernameHistoryItemDto> items;

  factory UsernameHistoryDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <UsernameHistoryItemDto>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          items.add(UsernameHistoryItemDto.fromJson(item));
        }
      }
    }
    return UsernameHistoryDto(items: items);
  }
}
