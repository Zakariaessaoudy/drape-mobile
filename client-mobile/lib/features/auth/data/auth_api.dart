import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthApi {
  AuthApi({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authenticate(
        ApiConstants.authLogin,
        LoginRequest(email: email.trim(), password: password).toJson(),
      );
    } catch (_) {
      throw const AuthException('Invalid email or password');
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _authenticate(
        ApiConstants.authRegister,
        RegisterRequest(
          name: name.trim(),
          email: email.trim(),
          password: password,
        ).toJson(),
      );
    } catch (_) {
      throw const AuthException('Could not create this account');
    }
  }

  Future<AuthResponse> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    final json =
        await _apiClient.post(path, body: body, authenticated: false)
            as Map<String, dynamic>;

    final response = AuthResponse.fromJson(json);
    await _tokenStorage.saveToken(response.token);
    return response;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
