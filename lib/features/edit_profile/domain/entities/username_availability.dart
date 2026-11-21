/// Status ketersediaan handle dari GET /users/me/username-availability.
enum UsernameAvailabilityStatus {
  available,
  current,
  invalid,
  reserved,
  taken,
  /// Hold aktif milik sendiri - boleh reclaim tanpa cooldown (#257).
  reclaimable,
  /// Sedang menunggu respons server (debounce).
  checking,
  /// Belum dicek / idle.
  idle,
}

UsernameAvailabilityStatus usernameAvailabilityFromWire(String raw) {
  return switch (raw) {
    'available' => UsernameAvailabilityStatus.available,
    'current' => UsernameAvailabilityStatus.current,
    'invalid' => UsernameAvailabilityStatus.invalid,
    'reserved' => UsernameAvailabilityStatus.reserved,
    'taken' => UsernameAvailabilityStatus.taken,
    'reclaimable' => UsernameAvailabilityStatus.reclaimable,
    _ => UsernameAvailabilityStatus.invalid,
  };
}

class UsernameAvailability {
  const UsernameAvailability({
    required this.username,
    required this.status,
  });

  final String username;
  final UsernameAvailabilityStatus status;
}
