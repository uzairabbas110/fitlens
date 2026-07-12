import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitlens/features/profile/data/models/user_model.dart';
// Repository that wraps all FirebaseAuth operations.
// Keeping Firebase logic here (not in UI) makes the app easier to test and maintain.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream that notifies listeners whenever the user's login state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Returns the currently signed-in user, or null if no one is signed in
  User? get currentUser => _firebaseAuth.currentUser;

  // Logs in an existing user with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Convert Firebase's error codes into readable messages
      throw _mapFirebaseError(e);
    }
  }

  // Creates a new account with email and password
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        fullName: fullName,
        email: email.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());

    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Signs the current user out
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Converts Firebase error codes into simple, user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}