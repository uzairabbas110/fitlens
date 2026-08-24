/// Provides the id of the currently authenticated user.
///
/// The domain layer depends only on this abstraction and never imports
/// Firebase Authentication directly.
abstract class CurrentUserIdProvider {
  const CurrentUserIdProvider();

  /// Returns the currently authenticated user's id.
  ///
  /// Returns `null` if no user is signed in.
  String? getCurrentUserId();
}