import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provides a single shared instance of AuthRepository across the app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Represents the current state of an auth action (login/signup/delete)
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool wasReactivated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.wasReactivated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? wasReactivated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      wasReactivated: wasReactivated ?? this.wasReactivated,
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
    state = state.copyWith(isLoading: true, errorMessage: null, wasReactivated: false);
    try {
      final restored = await _authRepository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, wasReactivated: restored);
      return true; // success
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false; // failure
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null, wasReactivated: false);
    try {
      final restored = await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false, wasReactivated: restored);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.resendVerificationEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // Requests account deletion with 10-day recovery grace period
  Future<bool> requestAccountDeletion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.requestAccountDeletion();
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