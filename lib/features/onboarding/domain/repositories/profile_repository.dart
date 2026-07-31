import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile?> getProfile(String uid);

  Future<void> saveProfile(Profile profile);

  /// Stores a CV or portfolio file (base64-encoded, in Firestore — see
  /// ProfileRemoteDataSource for why) and returns its generated file ID.
  Future<String> uploadDocument({
    required String uid,
    required String fileName,
    required List<int> bytes,
  });

  /// Marks `users/{uid}.onboardingCompleted = true` so the router lets the
  /// user through to the app shell.
  Future<void> markOnboardingComplete(String uid);
}
