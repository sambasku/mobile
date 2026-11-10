class UsernameAvailabilityDto {
  const UsernameAvailabilityDto({
    required this.username,
    required this.status,
  });

  final String username;
  final String status;

  factory UsernameAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return UsernameAvailabilityDto(
      username: json['username'] as String? ?? '',
      status: json['status'] as String? ?? 'invalid',
    );
  }
}
