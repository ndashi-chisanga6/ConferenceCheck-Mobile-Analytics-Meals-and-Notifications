import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/storage/selected_event_storage.dart';
import 'package:conference_check_mobile/core/storage/token_storage.dart';
import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/auth/data/auth_api.dart';
import 'package:conference_check_mobile/features/auth/data/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.initialized = false,
    this.error,
  });

  final AppUser? user;
  final bool loading;
  final bool initialized;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? loading,
    bool? initialized,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthApi _api = ref.read(authApiProvider);
  late final TokenStorage _tokenStorage = ref.read(tokenStorageProvider);
  late final SelectedEventStorage _eventStorage = ref.read(
    selectedEventStorageProvider,
  );

  @override
  AuthState build() {
    Future.microtask(bootstrap);
    return const AuthState(loading: true);
  }

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    final token = await _tokenStorage.read();
    if (token == null) {
      state = const AuthState(initialized: true);
      return;
    }
    try {
      final user = await _api.me();
      state = AuthState(user: user, initialized: true);
    } catch (error) {
      await _tokenStorage.clear();
      state = AuthState(initialized: true, error: error.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _api.login(email, password);
      await _tokenStorage.save(session.token);
      state = AuthState(user: session.user, initialized: true);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Token cleanup still happens locally for demo resilience.
    }
    await _tokenStorage.clear();
    await _eventStorage.clear();
    state = const AuthState(initialized: true);
  }
}
