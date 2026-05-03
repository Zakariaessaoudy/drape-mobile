class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.email,
    required this.name,
  });

  final String token;
  final String email;
  final String name;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}
