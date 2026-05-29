import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _nameKey = 'auth_name';

  Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
    await preferences.setString(_emailKey, email);
    await preferences.setString(_nameKey, name);
  }

  Future<String?> readToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  Future<SavedUserInfo> readUserInfo() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final savedEmail = preferences.getString(_emailKey);

    return SavedUserInfo(
      name: preferences.getString(_nameKey),
      email: savedEmail ?? _subjectFromToken(token),
    );
  }

  Future<bool> hasToken() async {
    final token = await readToken();
    if (token == null || token.isEmpty) return false;

    if (_isExpired(token)) {
      await clearToken();
      return false;
    }

    return true;
  }

  Future<void> clearToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_nameKey);
  }

  bool _isExpired(String token) {
    try {
      final payload = _decodePayload(token);
      final exp = payload['exp'];
      if (exp is! num) return false;

      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= nowSeconds;
    } catch (_) {
      return true;
    }
  }

  String? _subjectFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final subject = _decodePayload(token)['sub'];
      if (subject is String && subject.trim().isNotEmpty) {
        return subject.trim();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token');
    }

    return jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        )
        as Map<String, dynamic>;
  }
}

class SavedUserInfo {
  const SavedUserInfo({required this.name, required this.email});

  final String? name;
  final String? email;

  String get displayName {
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final emailName = email?.split('@').first.trim();
    if (emailName != null && emailName.isNotEmpty) {
      return emailName;
    }

    return 'CoutureMember';
  }
}
