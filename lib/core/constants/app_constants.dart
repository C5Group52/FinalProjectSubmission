abstract final class AppConstants {
  /// CV/portfolio files are stored as base64 in Firestore (not Cloud
  /// Storage, which now requires the paid Blaze plan — see README "Known
  /// Limitations"). Firestore documents cap at 1MiB; this leaves headroom
  /// for base64's ~33% size inflation plus surrounding fields. Enforced
  /// both here (picker UI, immediate feedback) and in
  /// ProfileRemoteDataSource (defense-in-depth) and firestore.rules
  /// (server-side backstop).
  static const int maxUploadFileSizeBytes = 700 * 1024;
}