class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'attendee',
      phone: json['phone']?.toString(),
    );
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AppUser user;
  final String token;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
    );
  }
}
