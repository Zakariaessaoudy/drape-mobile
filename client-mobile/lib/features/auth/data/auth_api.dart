import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

export '../../../core/network/api_client.dart' show ApiException;

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
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw const AuthException('Invalid email or password');
      }
      throw AuthException('Could not sign in: ${e.message}');
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
    } on ApiException catch (e) {
      throw AuthException('Could not create account: ${e.message}');
    } catch (e) {
      throw AuthException('Could not create account: ${e.toString()}');
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
    await _tokenStorage.saveSession(
      token: response.token,
      email: response.email,
      name: response.name,
    );
    return response;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
