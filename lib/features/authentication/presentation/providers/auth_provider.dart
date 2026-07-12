import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// Provides a single shared instance of AuthRepository across the app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Represents the current state of an auth action (login/signup)
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      // Passing null explicitly clears the previous error
      errorMessage: errorMessage,
    );
  }
}

// Controller that screens call into. Holds loading/error state
// and delegates actual work to AuthRepository.
class AuthController extends Notifier<AuthState> {

  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.login(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true; // success
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false; // failure
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.signUp(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

// Exposes the AuthController to the UI
final authControllerProvider =
NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

// Exposes the live stream of auth state changes (logged in / logged out)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});