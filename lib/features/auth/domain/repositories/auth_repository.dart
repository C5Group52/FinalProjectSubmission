import '../entities/app_user.dart';

abstract interface class AuthRepository {
  /// Emits the current user (or null when signed out). Backed by a live
  /// Firestore listener so `onboardingCompleted` updates reach the router as
  /// soon as onboarding finishes.
  Stream<AppUser?> authStateChanges();

  /// Last value seen on [authStateChanges], for callers that can't await.
  AppUser? get currentUser;

  Future<AppUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
