import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

class ProfileState {
  const ProfileState({
    this.displayName = 'CoutureMember',
    this.email,
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final String displayName;
  final String? email;
  final bool loading;
  final bool loaded;
  final String? error;

  String get initials {
    final words = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'CM';
    if (words.length == 1) {
      final end = words.first.length < 2 ? words.first.length : 2;
      return words.first.substring(0, end).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  ProfileState copyWith({
    String? displayName,
    String? email,
    bool? loading,
    bool? loaded,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadIfNeeded() async {
    if (state.loaded || state.loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final userInfo = await ref.read(tokenStorageProvider).readUserInfo();
      state = ProfileState(
        displayName: userInfo.displayName,
        email: userInfo.email,
        loaded: true,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        loaded: true,
        error: 'Could not load profile',
      );
    }
  }
}
