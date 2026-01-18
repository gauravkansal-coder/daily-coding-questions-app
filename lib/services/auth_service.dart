// Login, Signup, SignOut logic
class AuthService {
  /// Sign up user with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // TODO: Implement Firebase sign up
    throw UnimplementedError('Sign up not implemented');
  }

  /// Sign in user with email and password
  Future<void> signIn({required String email, required String password}) async {
    // TODO: Implement Firebase sign in
    throw UnimplementedError('Sign in not implemented');
  }

  /// Sign out current user
  Future<void> signOut() async {
    // TODO: Implement Firebase sign out
    throw UnimplementedError('Sign out not implemented');
  }

  /// Get current user ID
  String? getCurrentUserId() {
    // TODO: Implement get current user ID
    return null;
  }
}
