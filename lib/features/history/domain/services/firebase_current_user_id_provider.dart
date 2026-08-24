import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/services/current_user_id_provider.dart';

/// Firebase implementation of [CurrentUserIdProvider].
///
/// Reads the currently authenticated user's uid from Firebase
/// Authentication.
class FirebaseCurrentUserIdProvider implements CurrentUserIdProvider {
  final FirebaseAuth auth;

  const FirebaseCurrentUserIdProvider({
    required this.auth,
  });

  @override
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }
}