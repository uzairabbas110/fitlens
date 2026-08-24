import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitlens/features/profile/data/models/user_model.dart';

// Repository that wraps all FirebaseAuth operations and handles account lifecycle (including 10-day soft deletion & restoration)
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream that notifies listeners whenever the user's login state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Returns the currently signed-in user, or null if no one is signed in
  User? get currentUser => _firebaseAuth.currentUser;

  // Logs in an existing user with email and password, handling 10-day restoration & purge
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null && !credential.user!.emailVerified) {
        await _firebaseAuth.signOut();
        throw 'Please verify your email address. Check your inbox for the verification link.';
      }

      if (credential.user != null) {
        return await _checkAndHandleDeletionStatus(credential.user!);
      }
      return false;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred.';
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

      await credential.user?.sendEmailVerification();
      await _firebaseAuth.signOut(); // Force logout so they must verify

    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Resends verification email for a user who tries to log in but isn't verified
  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Signs the current user out
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Schedules account for permanent deletion with a 10-day grace period
  Future<void> requestAccountDeletion() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw 'No user is currently signed in.';

    final tenDaysLater = DateTime.now().add(const Duration(days: 10));

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'status': 'pending_deletion',
      'deletionRequestedAt': FieldValue.serverTimestamp(),
      'scheduledPermanentDeletionAt': Timestamp.fromDate(tenDaysLater),
    }, SetOptions(merge: true));

    await _firebaseAuth.signOut();
  }

  // Permanently erases all user data across all database collections
  static Future<void> permanentlyPurgeUserData(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Delete user subcollections
    final historyDocs = await firestore.collection('users').doc(uid).collection('history').get();
    for (final doc in historyDocs.docs) {
      await doc.reference.delete();
    }

    final measurementDocs = await firestore.collection('users').doc(uid).collection('measurements').get();
    for (final doc in measurementDocs.docs) {
      await doc.reference.delete();
    }

    // 2. Delete closet items
    final closetDocs = await firestore.collection('closet_items').where('userId', isEqualTo: uid).get();
    for (final doc in closetDocs.docs) {
      await doc.reference.delete();
    }

    // 3. Delete color analysis document
    await firestore.collection('color_analysis').doc(uid).delete();

    // 4. Delete stylist chats
    final chatDocs = await firestore.collection('stylist_chats').where('userId', isEqualTo: uid).get();
    for (final doc in chatDocs.docs) {
      await doc.reference.delete();
    }

    // 5. Delete root user document
    await firestore.collection('users').doc(uid).delete();
  }

  // Evaluates whether account is scheduled for deletion: restores if within 10 days, or purges if expired
  Future<bool> _checkAndHandleDeletionStatus(User user) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data['status'] == 'pending_deletion') {
        final scheduledTimestamp = data['scheduledPermanentDeletionAt'] as Timestamp?;
        final scheduledDate = scheduledTimestamp?.toDate();

        if (scheduledDate != null && DateTime.now().isAfter(scheduledDate)) {
          // 10-day grace period has passed -> permanently purge everything!
          await permanentlyPurgeUserData(user.uid);
          await user.delete();
          await _firebaseAuth.signOut();
          throw 'This account was permanently deleted after the 10-day grace period expired.';
        } else {
          // Within 10-day grace period -> reactivate account!
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'status': 'active',
            'deletionRequestedAt': FieldValue.delete(),
            'scheduledPermanentDeletionAt': FieldValue.delete(),
            'restoredAt': FieldValue.serverTimestamp(),
          });
          return true; // was restored
        }
      }
    }
    return false;
  }

  // Signs in or registers a user via Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          final userModel = UserModel(
            uid: user.uid,
            fullName: user.displayName ?? 'Google User',
            email: user.email ?? '',
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          return false;
        } else {
          return await _checkAndHandleDeletionStatus(user);
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
    }
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
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked. Please allow popups for this site.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}