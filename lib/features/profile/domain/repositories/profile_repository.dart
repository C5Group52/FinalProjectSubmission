import '../../../onboarding/domain/entities/profile.dart';

/// Read/edit access to an already-saved [Profile].
///
/// [Profile] is reused from the onboarding feature rather than redefined
/// here: it mirrors a single ERD entity stored once at `profiles/{uid}`, and
/// onboarding's submit flow is what first creates it. This repository only
/// covers what the profile feature itself needs afterwards — viewing it and
/// editing it — as opposed to onboarding's one-time wizard submission.
abstract interface class ProfileRepository {
  Future<Profile?> getProfile(String uid);

  /// Persists edits to an existing profile (skills, education, languages,
  /// qualifications, headline).
  Future<void> updateProfile(Profile profile);

  /// Attaches a new/replacement CV or portfolio file and returns its
  /// generated file ID. Storage details mirror onboarding's upload path
  /// (base64-encoded, in Firestore — see ProfileRemoteDataSource).
  Future<String> uploadDocument({
    required String uid,
    required String fileName,
    required List<int> bytes,
  });
}
