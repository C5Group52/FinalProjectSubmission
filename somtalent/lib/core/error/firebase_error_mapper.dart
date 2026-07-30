import 'package:firebase_auth/firebase_auth.dart';

import 'failure.dart';

/// Translates raw Firebase exceptions into polite, user-facing [Failure]s.
/// Keeps Firebase error codes out of the presentation layer entirely.
abstract final class FirebaseErrorMapper {
  static Failure fromAuthException(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'That email address looks invalid.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      'user-not-found' => 'No account found with that email.',
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' =>
        'An account with this email already exists. Try signing in instead.',
      'weak-password' =>
        'Choose a stronger password (8+ characters, letters and numbers).',
      'operation-not-allowed' =>
        'This sign-in method is currently unavailable.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Check your network and try again.',
      'account-exists-with-different-credential' =>
        'An account already exists with this email using a different sign-in method.',
      'requires-recent-login' =>
        'Please sign in again to complete this action.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
    return AuthFailure(message);
  }

  static Failure fromFirestoreException(FirebaseException e) {
    final message = switch (e.code) {
      'permission-denied' => 'You don\'t have permission to do that.',
      'unavailable' => 'Service temporarily unavailable. Please try again.',
      'not-found' => 'The requested item could not be found.',
      _ => e.message ?? 'Something went wrong. Please try again.',
    };
    return ServerFailure(message);
  }

  static Failure fromUnknown(Object error) {
    if (error is FirebaseAuthException) return fromAuthException(error);
    if (error is FirebaseException) return fromFirestoreException(error);
    return const UnknownFailure();
  }
}