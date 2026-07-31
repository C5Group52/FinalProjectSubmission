/// Firestore collection paths. Kept in one place and mirrored exactly by
/// `docs/ERD.md` and `firestore.rules` — if you add a collection, update all
/// three.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String profiles = 'profiles';
  static const String jobs = 'jobs';
  static const String applications = 'applications';
  static const String careerResources = 'careerResources';
  static const String conversations = 'conversations';

  static const String savedJobsSubcollection = 'savedJobs';
  static const String transactionsSubcollection = 'transactions';
  static const String notificationsSubcollection = 'notifications';
  static const String careerMeetingsSubcollection = 'careerMeetings';
  static const String messagesSubcollection = 'messages';
  static const String filesSubcollection = 'files';
}