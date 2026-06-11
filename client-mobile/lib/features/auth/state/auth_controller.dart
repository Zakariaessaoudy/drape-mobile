import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../outfits/state/outfit_list_controller.dart';
import '../../wardrobe/state/wardrobe_controller.dart';
import '../data/auth_api.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.error});

  const AuthState.checking() : this(status: AuthStatus.checking);

  const AuthState.authenticated() : this(status: AuthStatus.authenticated);

  const AuthState.unauthenticated({String? error})
    : this(status: AuthStatus.unauthenticated, error: error);

  final AuthStatus status;
  final String? error;

  bool get isLoading => status == AuthStatus.checking;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.checking();

  Future<void> checkSession() async {
    final hasToken = await ref.read(tokenStorageProvider).hasToken();
    state = hasToken
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState.checking();
    try {
      await ref.read(authApiProvider).login(email: email, password: password);
      state = const AuthState.authenticated();
      return true;
    } on AuthException catch (error) {
      state = AuthState.unauthenticated(error: error.message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.checking();
    try {
      await ref
          .read(authApiProvider)
          .register(name: name, email: email, password: password);
      state = const AuthState.authenticated();
      return true;
    } on AuthException catch (error) {
      state = AuthState.unauthenticated(error: error.message);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearToken();
    ref.invalidate(wardrobeControllerProvider);
    ref.invalidate(outfitListControllerProvider);
    state = const AuthState.unauthenticated();
  }
}
