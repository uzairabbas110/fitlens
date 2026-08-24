import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/services/current_user_id_provider.dart';

class FirebaseCurrentUserIdProvider extends CurrentUserIdProvider {
  final FirebaseAuth auth;

  const FirebaseCurrentUserIdProvider({required this.auth});

  @override
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }
}
